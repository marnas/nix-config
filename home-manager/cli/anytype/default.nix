{
  pkgs,
  lib,
  config,
  ...
}:
let
  # `any` — verb-based CLI over the self-hosted Anytype Local API (create / list /
  # search / read / update / delete objects in your space). Targets the space whose id
  # is in Infisical (secret `ANYTYPE_SPACE_ID`); `any --space <id> …` overrides per call.
  # Script body lives in ./any.sh; curl/jq are put on PATH by writeShellApplication
  # (which also shellchecks it at build).
  #
  # `infisical` + `infisical-token` are deliberately NOT in runtimeInputs: they live in
  # home.packages (see ../infisical) and the script inherits them from PATH. The token
  # mint inside `infisical-token` in turn shells out to the platform-wrapped `op` from
  # PATH (1Password desktop integration only works through that wrapper, not the plain
  # nixpkgs CLI). Net: `any` no longer prompts 1Password per call — the apikey is fetched
  # from Infisical at call time and discarded; `op` is hit at most once per boot.
  any = pkgs.writeShellApplication {
    name = "any";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = builtins.readFile ./any.sh;
  };

  # Always-on headless node behind the capture API. `anytype-cli serve` runs the
  # local-first daemon: it writes objects locally and pushes them to the self-hosted
  # any-sync bundle (so desktop/iOS pull on next sync) and serves the REST API on
  # 127.0.0.1:31012 that `any` talks to. Declarative on purpose — NOT the imperative
  # `anytype-cli service install`. Needs a per-machine daemon because the API is
  # localhost-only, so it runs on both NixOS (systemd) and macOS (launchd).
  serveArgs = [
    "${pkgs.anytype-cli}/bin/anytype-cli"
    "serve"
    "--quiet"
    "--no-update-check"
  ];
in
{
  home.packages = [ any ];

  systemd.user.services = lib.mkIf pkgs.stdenv.isLinux {
    anytype-cli = {
      Unit = {
        Description = "Anytype headless daemon (local-first node + REST API on :31012)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = lib.escapeShellArgs serveArgs;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  launchd.agents = lib.mkIf pkgs.stdenv.isDarwin {
    anytype-cli = {
      enable = true;
      config = {
        ProgramArguments = serveArgs;
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/anytype-cli.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/anytype-cli.log";
      };
    };
  };
}

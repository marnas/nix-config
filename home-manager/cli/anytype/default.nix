{ pkgs, lib, config, ... }:
let
  # `any` — verb-based CLI over the self-hosted Anytype Local API (create / list /
  # search / read / update / delete objects in your space). Targets the space whose id
  # is in 1Password (field `space_id`); `any --space <id> …` overrides per call. Script
  # body lives in ./any.sh; curl/jq are put on PATH by writeShellApplication (which also
  # shellchecks it at build).
  #
  # `op` is deliberately NOT in runtimeInputs: 1Password desktop-app CLI integration
  # only works through the platform's wrapped `op` (e.g. the NixOS setuid wrapper at
  # /run/wrappers/bin/op). Bundling the plain nixpkgs _1password-cli would shadow that
  # and break with "connection reset" — so the script inherits the user's `op` from PATH.
  any = pkgs.writeShellApplication {
    name = "any";
    runtimeInputs = with pkgs; [ curl jq ];
    text = builtins.readFile ./any.sh;
  };

  # Always-on headless node behind the capture API. `anytype-cli serve` runs the
  # local-first daemon: it writes objects locally and pushes them to the self-hosted
  # any-sync bundle (so desktop/iOS pull on next sync) and serves the REST API on
  # 127.0.0.1:31012 that `any` talks to. Declarative on purpose — NOT the imperative
  # `anytype-cli service install`. Needs a per-machine daemon because the API is
  # localhost-only, so it runs on both NixOS (systemd) and macOS (launchd).
  serveArgs = [ "${pkgs.anytype-cli}/bin/anytype-cli" "serve" "--quiet" "--no-update-check" ];
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

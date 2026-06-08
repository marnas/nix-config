{
  pkgs,
  ...
}:
let
  # `any` — verb-based CLI over the self-hosted Anytype REST API (create / list / search /
  # read / update / delete objects in your space). The API is served by ONE central
  # `anytype-cli serve` bot node in the cluster (apps/anytype/cli), reached over the tailnet
  # at https://api.anytype.marnas.sh — there is no per-machine daemon anymore. `any` targets
  # the space whose id is in Infisical (secret `ANYTYPE_SPACE_ID`); `any --space <id> …`
  # overrides per call. Script body lives in ./any.sh; curl/jq are put on PATH by
  # writeShellApplication (which also shellchecks it at build).
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
in
{
  home.packages = [ any ];
}

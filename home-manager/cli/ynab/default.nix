{
  pkgs,
  ...
}:
let
  # `ynab` — verb-based CLI over the YNAB API v1 (accounts / categories / transactions /
  # categorize / approve / create categories). Targets the default plan; `ynab --plan
  # <id> …` overrides per call. Script body lives in ./ynab.sh; curl/jq are put on PATH
  # by writeShellApplication (which also shellchecks it at build).
  #
  # `infisical-secrets` is deliberately NOT in runtimeInputs: it lives in home.packages
  # (see ../infisical) and the script inherits it from PATH, so the YNAB token is fetched
  # from Infisical (project `claude`, path /ynab) at call time and discarded — no secret
  # on disk, no per-call 1Password prompt (`op` is hit at most once per boot).
  ynab = pkgs.writeShellApplication {
    name = "ynab";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = builtins.readFile ./ynab.sh;
  };
in
{
  home.packages = [ ynab ];
}

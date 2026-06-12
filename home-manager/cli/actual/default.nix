{
  pkgs,
  ...
}:
{
  # `actual` — CLI over the official Actual Budget API for the self-hosted Actual
  # server (replaced the retired YNAB CLI 2026-06). Unlike `any` (a thin curl
  # wrapper), the official Actual interface is a Node package with a native dep, so
  # the derivation lives in pkgs/actual-cli (buildNpmPackage) and this module only
  # installs it.
  #
  # `infisical-secrets` is deliberately NOT a package dependency: it lives in
  # home.packages (see ../infisical) and the CLI inherits it from PATH, so the server
  # password + sync id are fetched from Infisical (project `claude`, path /actual) at
  # call time and discarded — no secret on disk, no per-call 1Password prompt.
  home.packages = [ pkgs.actual-cli ];
}

# Infisical CLI + the `infisical-token` bootstrap helper.
#
# Part of getting Claude off per-call 1Password prompts: instead of each tool reading a
# secret from 1Password at call time (one biometric prompt per call), tools fetch from
# the self-hosted Infisical (`infisical.marnas.sh`) using a short-lived machine-identity
# token that `infisical-token` mints once per boot (one `op` unlock) and caches in
# tmpfs. See ./infisical-token.sh and apps/infisical/SETUP.md in flux-config. This is
# the local-CLI phase; brokering Claude's *egress* secrets (Anthropic, GitHub) via an
# in-cluster Agent Vault + `agent-vault run -- claude` is a separate later phase.
{ pkgs, ... }:
let
  infisical-token = pkgs.writeShellApplication {
    name = "infisical-token";
    runtimeInputs = with pkgs; [
      curl
      jq
      infisical
    ];
    text = builtins.readFile ./infisical-token.sh;
  };
in
{
  home.packages = [
    pkgs.infisical
    infisical-token
  ];
}

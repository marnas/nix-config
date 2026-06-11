# Infisical CLI + the `infisical-token` / `infisical-secrets` helpers.
#
# Part of getting Claude off per-call 1Password prompts: instead of each tool reading a
# secret from 1Password at call time (one biometric prompt per call), tools fetch from
# the self-hosted Infisical (`infisical.marnas.sh`) using a short-lived machine-identity
# token that `infisical-token` mints once per boot (one `op` unlock) and caches in
# tmpfs. See ./infisical-token.sh and apps/infisical/SETUP.md in flux-config. This is
# the local-CLI phase; brokering Claude's *egress* secrets (Anthropic, GitHub) via an
# in-cluster Agent Vault + `agent-vault run -- claude` is a separate later phase.
#
# `infisical-secrets </path>` is the consumer-side companion: fetch one folder's secrets
# as flat JSON using that cached token, re-minting once on auth rejection. Per-API CLIs
# (`any`, `ynab`, ...) call it instead of each re-implementing the retry dance.
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
  infisical-secrets = pkgs.writeShellApplication {
    name = "infisical-secrets";
    runtimeInputs = [
      pkgs.jq
      pkgs.infisical
      infisical-token
    ];
    text = builtins.readFile ./infisical-secrets.sh;
  };
in
{
  home.packages = [
    pkgs.infisical
    infisical-token
    infisical-secrets
  ];
}

{
  pkgs,
  ...
}:
let
  # `sparky` — verb-based CLI over the SparkyFitness MCP endpoint (the app's AI-facing
  # API) at https://sparky.marnas.sh/mcp. Generic verbs (tools / schema / call) speak
  # JSON-RPC directly, so the CLI tracks whatever tool catalog the server exposes and
  # never needs updating when SparkyFitness upgrades. Script body lives in ./sparky.sh;
  # curl/jq are put on PATH by writeShellApplication (which also shellchecks it at
  # build). `infisical-secrets` is deliberately NOT in runtimeInputs: it lives in
  # home.packages (see ../infisical) and the script inherits it from PATH — same
  # arrangement as `any` (../anytype) and for the same 1Password-wrapper reason.
  sparky = pkgs.writeShellApplication {
    name = "sparky";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = builtins.readFile ./sparky.sh;
  };
in
{
  home.packages = [ sparky ];
}

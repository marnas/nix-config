{ pkgs, ... }:
let
  claudeLocal = pkgs.writeShellScriptBin "claude-local" ''
    exec env \
      ANTHROPIC_AUTH_TOKEN=ollama \
      ANTHROPIC_API_KEY="" \
      ANTHROPIC_BASE_URL=http://localhost:11434 \
      CLAUDE_CODE_ATTRIBUTION_HEADER=0 \
      claude --model qwen3-coder:30b "$@"
  '';
in
{
  home.packages = [ claudeLocal ];
}

{ pkgs, ... }:
let
  # Shared Anthropic-compatible env pointing Claude Code at local Ollama.
  localEnv = ''
    ANTHROPIC_AUTH_TOKEN=ollama \
    ANTHROPIC_API_KEY="" \
    ANTHROPIC_BASE_URL=http://localhost:11434 \
    CLAUDE_CODE_ATTRIBUTION_HEADER=0'';

  # Coder-tuned default.
  claudeLocal = pkgs.writeShellScriptBin "claude-local" ''
    exec env ${localEnv} \
      claude --model qwen3-coder:30b "$@"
  '';

  # Community Qwen3.5-9B distilled on Claude Opus reasoning traces. The 9B
  # (Q5_K_M, ~6.5 GB) stays fully GPU-resident on the 12 GB RX 6700 XT, unlike
  # the 35B which spilled to CPU and stalled the desktop. Opus-style reasoning,
  # not coding-tuned.
  claudeOpusLocal = pkgs.writeShellScriptBin "claude-opus-local" ''
    exec env ${localEnv} \
      claude --model hf.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF:Q5_K_M "$@"
  '';
in
{
  home.packages = [
    claudeLocal
    claudeOpusLocal
  ];
}

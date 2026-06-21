{ pkgs, ... }:
let
  # qwen-code's native target is qwen3-coder; OpenAI-compatible env vars
  # point it at local Ollama. Wrappers keep the bare `qwen` free for cloud use.
  qwenWrapper =
    name: model:
    pkgs.writeShellScriptBin name ''
      exec env \
        OPENAI_API_KEY=ollama \
        OPENAI_BASE_URL=http://localhost:11434/v1 \
        OPENAI_MODEL=${model} \
        ${pkgs.qwen-code}/bin/qwen "$@"
    '';

  # Coder-tuned default.
  qwenLocal = qwenWrapper "qwen-local" "qwen3-coder:30b";

  # Opus-distilled reasoning model (see claude-local.nix).
  qwenOpusLocal = qwenWrapper "qwen-opus-local" "hf.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF:Q5_K_M";
in
{
  home.packages = [
    pkgs.qwen-code
    qwenLocal
    qwenOpusLocal
  ];
}

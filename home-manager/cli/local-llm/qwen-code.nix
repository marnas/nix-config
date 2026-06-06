{ pkgs, ... }:
let
  # qwen-code's native target is qwen3-coder; OpenAI-compatible env vars
  # point it at local Ollama. Wrapper keeps the bare `qwen` free for cloud use.
  qwenLocal = pkgs.writeShellScriptBin "qwen-local" ''
    exec env \
      OPENAI_API_KEY=ollama \
      OPENAI_BASE_URL=http://localhost:11434/v1 \
      OPENAI_MODEL=qwen3-coder:30b \
      ${pkgs.qwen-code}/bin/qwen "$@"
  '';
in
{
  home.packages = [
    pkgs.qwen-code
    qwenLocal
  ];
}

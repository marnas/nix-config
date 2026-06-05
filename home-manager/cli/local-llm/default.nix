{ ... }:
{
  # CLI agents wired to local models via Ollama (http://localhost:11434).
  imports = [
    ./claude-local.nix
    ./goose.nix
    ./opencode.nix
    ./qwen-code.nix
  ];
}

{ pkgs, ... }:
{
  home.packages = [ pkgs.opencode ];

  # opencode needs the provider defined in config (can't be done via env).
  # It only reads this file, so the nix-store symlink is fine.
  # Note: the @ai-sdk/openai-compatible npm pkg is fetched at first run.
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama (local)";
      options.baseURL = "http://localhost:11434/v1";
      models."qwen3-coder:30b".name = "Qwen3 Coder 30B";
    };
    model = "ollama/qwen3-coder:30b";
  };
}

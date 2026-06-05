{ pkgs, ... }:
{
  home.packages = [ pkgs.goose-cli ];

  home.sessionVariables = {
    GOOSE_PROVIDER = "ollama";
    GOOSE_MODEL = "qwen3-coder:30b";
    OLLAMA_HOST = "http://localhost:11434";
  };
}

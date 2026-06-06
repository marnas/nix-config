{ pkgs, lib, vars, ... }:
{
  imports = [
    ./anytype
    ./atuin.nix
    ./bat.nix
    ./claude
    ./eza.nix
    ./fish.nix
    ./git.nix
    # ./music
    ./starship.nix
    ./tmux.nix
    ./yazi.nix
    ./zsh.nix
  ]
  # Local-LLM agents talk to a host-local Ollama; only the NixOS box runs it.
  ++ lib.optional (vars.hostname != "macos") ./local-llm;
  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them
    bc # Calculator
    bottom # System viewer
    btop
    fd # Better find
    ffmpeg
    jq # JSON pretty printer and manipulator
    httpie # Better curl
    ncdu # TUI disk usage
    nh # Nice wrapper for NixOS and HM
    nix-output-monitor
    nvd # Differ
    ripgrep # Better grep
  ];

  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
  };
}

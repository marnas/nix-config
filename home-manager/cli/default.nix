{ pkgs, ... }: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./eza.nix
    ./fish.nix
    ./git.nix
    ./yazi.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

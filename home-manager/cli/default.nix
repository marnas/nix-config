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
    ncdu # TUI disk usage
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    jq # JSON pretty printer and manipulator

    # stable.rnix-lsp
    nvd # Differ
    nix-output-monitor
    nh # Nice wrapper for NixOS and HM

    ltex-ls # Spell checking LSP
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

{
  pkgs,
  lib,
  vars,
  ...
}:
{
  imports = [
    ./actual
    ./anytype
    ./atuin.nix
    ./bat.nix
    ./claude
    ./eza.nix
    ./fish.nix
    ./git.nix
    ./infisical
    # ./music
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./yazi.nix
    ./zsh.nix
  ];
  # Local-LLM agents talk to a host-local Ollama; only the NixOS box runs it.
  # Disabled for now — not worth it yet; config kept under ./local-llm for future reuse.
  # ++ lib.optional (vars.hostname != "macos") ./local-llm;
  home.packages = with pkgs; [
    argocd # Argo CD CLI
    comma # Install and run programs by sticking a , before them
    bc # Calculator
    bottom # System viewer
    btop
    fd # Better find
    ffmpeg
    forgejo-cli # Forgejo CLI (fj), credential seeded from Infisical into tmpfs
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

{ inputs, outputs, pkgs, vars, ... }: {
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      inputs.marnas-nvim.overlays.default
    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "marnas";
    homeDirectory =
      if (vars.hostname == "macos") then "/Users/marnas" else "/home/marnas";

    packages = with pkgs; [
      btop
      nvim-pkg
      docker
      docker-compose
      golangci-lint

      # media
      yt-dlp

      # messaging
      slack
      discord

      # kubernetes
      talosctl
      kubectl
      kubernetes-helm
      conduktor-ctl
      terraform
      lens
      fluxcd
    ];

    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      SHELL = "${pkgs.fish}/bin/fish";
    };
  };

  programs.home-manager.enable = true;
}

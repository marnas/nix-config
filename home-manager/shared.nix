{ inputs, outputs, pkgs, ... }: {
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
    homeDirectory = "/home/marnas";
  };

  home.packages = with pkgs; [
    nvim-pkg
    kubernetes-helm
    lens

    # media
    plexamp
    yt-dlp

    # messaging
    slack
    telegram-desktop
    discord
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
  };

  programs.home-manager.enable = true;
}

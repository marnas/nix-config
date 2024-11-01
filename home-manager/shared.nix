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
      nvim-pkg
      kubernetes-helm
      terraform
      lens

      # media
      yt-dlp

      # messaging
      slack
      discord
    ];

    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      SHELL = "${pkgs.fish}/bin/fish";
    };
  };

  programs.home-manager.enable = true;
}

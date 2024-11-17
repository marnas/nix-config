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
      conduktor-ctl
      docker
      docker-compose
      fluxcd
      golangci-lint
      kubectl
      kubernetes-helm
      lens
      nvim-pkg
      slack
      talosctl
      terraform
      vesktop
      yt-dlp
    ];

    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      SHELL = "${pkgs.fish}/bin/fish";
    };
  };

  programs.home-manager.enable = true;
}

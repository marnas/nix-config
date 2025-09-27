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

  imports = [ ./desktop/alacritty.nix ./desktop/firefox.nix ];

  home = {
    username = "marnas";
    homeDirectory =
      if (vars.hostname == "macos") then "/Users/marnas" else "/home/marnas";

    packages = with pkgs; [
      awscli2
      conduktor-ctl
      docker
      docker-compose
      fluxcd
      golangci-lint
      yq-go
      k3d
      kubectl
      kubernetes-helm
      lens
      nvim-pkg
      powershell
      slack
      talosctl
      telegram-desktop
      teleport
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

  programs = {
    home-manager.enable = true;

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        # prompt = "enabled";
      };
    };
    go.enable = true;
    k9s.enable = true;
  };

}

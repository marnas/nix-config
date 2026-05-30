{
  inputs,
  outputs,
  lib,
  pkgs,
  vars,
  ...
}:
{
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

  imports = [
    ./desktop/alacritty.nix
    ./desktop/ghostty.nix
    ./desktop/firefox.nix
  ];

  home = {
    username = if (vars.hostname == "macos") then "marco.santonastaso" else "marnas";
    homeDirectory = if (vars.hostname == "macos") then "/Users/marco.santonastaso" else "/home/marnas";

    packages = with pkgs; [
      awscli2
      fluxcd
      jellyfin-tui
      kubectl
      kubernetes-helm
      lens
      nvim-pkg
      talosctl
      terraform
      yt-dlp
    ];

    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
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
  };

  services.ollama = {
    enable = true;
    # Linux uses ROCm with a gfx version spoof for Navi 22 (gfx1031 -> gfx1030).
    # macOS uses Metal via the default ollama package and ignores these.
    acceleration = lib.mkIf pkgs.stdenv.isLinux "rocm";
    environmentVariables = lib.mkIf pkgs.stdenv.isLinux {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };

}

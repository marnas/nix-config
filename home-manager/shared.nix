{
  inputs,
  outputs,
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
    ./desktop/nextcloud.nix
  ];

  home = {
    username = if (vars.hostname == "macos") then "marco.santonastaso" else "marnas";
    homeDirectory = if (vars.hostname == "macos") then "/Users/marco.santonastaso" else "/home/marnas";

    packages = with pkgs; [
      awscli2
      fluxcd
      element-desktop
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

}

{ inputs
, outputs
, pkgs
, lib
, config
, ...
}: {

  imports = [
    ./cli
    ./desktop/alacritty.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "marnas";
    homeDirectory = "/Users/marnas";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    neovim
    vscode
    discord
    alacritty
    lens
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Marco Santonastaso";
    userEmail = "marco@santonastaso.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}

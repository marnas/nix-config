{ inputs
, outputs
, pkgs
, ...
}: {

  imports = [
    ./cli
    ./desktop
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
    homeDirectory = "/home/marnas";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    chromium
    teams-for-linux
    postman
    orca-slicer
    kubernetes-helm
    gamemode
    slack
    telegram-desktop
    discord
    element-desktop
    whatsapp-for-linux
    steam
    lutris
    plexamp
    gimp
    nextcloud-client
    gnome.eog
    swaybg
    lens
    libreoffice
    zathura
    texliveFull
    pulsemixer
    vlc
    yt-dlp
    prismlauncher
    sunshine
    # inputs.nix-gaming.packages.${pkgs.system}.star-citizen
    inputs.nix-citizen.packages.${pkgs.system}.star-citizen
    inputs.nix-citizen.packages.${pkgs.system}.lug-helper
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CURRENT_DESKTOP = "hyprland";
    TERMINAL = "alacritty";
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}

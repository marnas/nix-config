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
    postman
    orca-slicer
    kubernetes-helm
    plexamp
    gimp
    nextcloud-client
    nemo
    eog
    swaybg
    lens
    libreoffice
    zathura
    pulsemixer
    vlc
    yt-dlp
    soulseekqt

    # messaging
    teams-for-linux
    slack
    telegram-desktop
    discord
    whatsapp-for-linux

    # gaming
    gamemode
    steam
    lutris
    clonehero
    wowup-cf
    prismlauncher
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
    TERMINAL = "alacritty";
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

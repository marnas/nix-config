{ pkgs, inputs, ... }: {

  imports = [ ./cli ./desktop ./shared.nix ];

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    chromium
    clonehero
    eog
    freetube
    gimp
    inputs.zen-browser.packages."${system}".default
    libreoffice
    lutris
    nemo-with-extensions
    nicotine-plus
    obsidian
    # orca-slicer
    plexamp
    postman
    prismlauncher
    protonup-qt
    pulsemixer
    # soulseekqt
    transgui
    vlc
    # whatsie
    whatsapp-for-linux
    wowup-cf
    zathura
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

  services.nextcloud-client.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}

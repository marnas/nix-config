{ config, pkgs, pkgs-stable, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      postman = prev.postman.overrideAttrs (old: rec {
        version = "20230716100528";
        src = final.fetchurl {
          url = "https://web.archive.org/web/${version}/https://dl.pstmn.io/download/latest/linux_64";
          sha256 = "sha256-svk60K4pZh0qRdx9+5OUTu0xgGXMhqvQTGTcmqBOMq8=";

          name = "${old.pname}-${version}.tar.gz";
        };
      });
    })
  ];

  imports =
    [
      ./hardware-configuration.nix
      ./virtmanager.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  virtualisation.docker.enable = true;

  boot.kernelParams = [
    "video=DP-1:2560x1440@75"
    "video=DP-2:2560x1440@75"
  ];

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = true;

  # I use zsh btw
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fonts.packages = with pkgs; [
    nerdfonts
    meslo-lgs-nf
  ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marnas = {
    isNormalUser = true;
    description = "marnas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox-wayland
      #  thunderbird
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    gcc
    go
    sshfs
    cargo
    nodejs
    ripgrep
    bat
    alacritty
    oh-my-zsh
    teams-for-linux
    postman
    orca-slicer
    wine
    winetricks
    bottles
    unzip
    btop
    telegram-desktop
    discord
    whatsapp-for-linux
    steam
    lutris
    vifm
    docker
    docker-compose
    kubectl
    apple-cursor
    plexamp
    zathura
    texliveFull
    gimp
    ollama
    pulsemixer
    nextcloud-client
    vlc
    gnome.eog
    lens

    polkit
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    mesa
    wayland
    xwayland
    waybar
    wl-clipboard
    wofi
    kitty
    meson
    wayland-protocols
    wayland-utils
    wlroots
    grim
    slurp
    libnotify
    swaynotificationcenter
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    polkit-kde-agent
  ];

  programs.thunar.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "marnas" ];
  };

  security.polkit.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

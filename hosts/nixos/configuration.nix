{ inputs
, outputs
, config
, lib
, pkgs
, ...
}:

{
  imports =
    [
      ./hardware-configuration.nix
      ./virtmanager.nix
      ./greetd.nix

      ../shared/fish.nix
    ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  # nix.nixPath = [ "/etc/nix/path" ];
  # environment.etc =
  #   lib.mapAttrs'
  #     (name: value: {
  #       name = "nix/path/${name}";
  #       value.source = value.flake;
  #     })
  #     config.nix.registry;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;

  hardware.opengl = {
    # Mesa
    enable = true;
    # Vulkan
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      amdvlk
    ];
    # For 32 bit applications 
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];

  };

  virtualisation.docker.enable = true;

  boot.kernelParams = [
    "video=DP-1:2560x1440@75"
    "video=DP-2:2560x1440@360"
    "clearcpuid=304" # The Finals
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [
        # { from = 47984; to = 48010; } # Sunshine
        # { from = 1714; to = 1764; } # KDE Connect
      ];
      allowedUDPPortRanges = [
        # { from = 47984; to = 48010; } # Sunshine
        # { from = 1714; to = 1764; } # KDE Connect
      ];
    };
    extraHosts = "127.0.0.1 modules-cdn.eac-prod.on.epicgames.com"; # Patch for Star Citizen
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  services.dbus.enable = true;

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
    wireplumber.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marnas = {
    isNormalUser = true;
    description = "marnas";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      home-manager
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    gcc
    go
	python3
	python311Packages.nats-python
    sshfs
    cargo
    nodejs
    alacritty
    wine
    winetricks
    protonup-qt
    bottles
    unzip
    btop
    docker
    docker-compose
    kubectl
    soulseekqt
    natscli
	nmap
	wowup
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

  # NixOS configuration for Star Citizen requirements
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

{ pkgs, ... }:

{
  imports = [
    ../shared/fish.nix
    ../shared/nix.nix
    ../shared/restic.nix

    ./gnome.nix
    ./hardware.nix
    # ./virtmanager.nix
  ];

  virtualisation.docker.enable = true;

  services = {
    dbus.enable = true;
    tailscale.enable = true;

    xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
    # Enable CUPS to print documents.
    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      jack.enable = true;
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    open-webui = {
      port = 9077;
      enable = false;
    };
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    nerd-fonts.fira-code
    noto-fonts-emoji
    meslo-lgs-nf
  ];

  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
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
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.marnas = {
    isNormalUser = true;
    description = "marnas";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ home-manager ];
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      git
      gcc
      gnumake
      python3
      cargo
      nodejs
      stable.protonup-qt
      unzip
      # awscli2
      transgui
      cifs-utils
    ];

    etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
        '';
        mode = "0755";
      };
    };

    # To  run slack under wayland
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;

    hyprland.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marnas" ];

    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remote Play
    };
    gamemode.enable = true;
  };

  security = {
    rtkit.enable = true; # Enable sound with pipewire.
    polkit.enable = true;
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
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

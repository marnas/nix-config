{ pkgs, ... }:

{
  imports = [
    ../shared
    # ../shared/restic.nix
    ./gnome

    ./hardware.nix
    # ./virtmanager.nix
  ];

  virtualisation.docker.enable = true;

  services = {
    dbus.enable = true;
    tailscale.enable = true;

    # Enable Avahi with user service publishing for MPD
    avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

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

      # Audiophile configuration for high-quality audio and multiple sample rates
      extraConfig.pipewire."99-audiophile" = {
        "context.properties" = {
          # Support multiple sample rates for bit-perfect playback
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            176400
            192000
            352800
            384000
          ];
          # Default to 48kHz when idle
          "default.clock.rate" = 48000;
          # Reasonable quantum for non-real-time audiophile use
          "default.clock.quantum" = 1024;
        };
      };

      # High-quality resampling when needed
      extraConfig.pipewire-pulse."99-audiophile" = {
        "stream.properties" = {
          # Resample quality: 10 = high quality, 15 = max (but 3x CPU load)
          "resample.quality" = 10;
        };
      };
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    flatpak.enable = true;
    teleport.enable = true;
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    meslo-lgs-nf
  ];

  environment = {
    systemPackages = with pkgs; [
      wget
      gcc
      gnumake
      unzip
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
    dconf.enable = true;

    hyprland.enable = true; # To show hyprland in GDM

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marnas" ];
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      protontricks.enable = true;
    };
    gamemode.enable = true;

    # Wine/Lutris support
    nix-ld.enable = true; # For running unpatched binaries
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
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
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

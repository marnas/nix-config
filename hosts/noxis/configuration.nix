{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
    ./transmission.nix
    # ./terraria.nix

    ../shared/fish.nix
    ../shared/nix.nix
    ../shared/openssh.nix
  ];

  nixpkgs = { overlays = [ inputs.marnas-nvim.overlays.default ]; };

  nix.settings.trusted-users = [ "marnas" ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.tailscale.enable = true;

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

  users.users.marnas = {
    isNormalUser = true;
    description = "marnas";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ home-manager ];
  };

  networking = {
    hostName = "noxis"; # Define your hostname.
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 25570 25565 ];
      allowedUDPPorts = [ 25570 25565 19132 ];
      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];
      # To allow tailscale exit nodes without losing internet access.
      checkReversePath = "loose";
    };
  };

  environment.systemPackages = with pkgs; [
    nvim-pkg
    update-systemd-resolved
    git
  ];

  system.stateVersion = "23.11";

}

{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./minecraft.nix
    ./transmission.nix
    # ./terraria.nix

    ../shared
    ../shared/openssh.nix
  ];

  nix.settings.trusted-users = [ "marnas" ];

  services.tailscale.enable = true;

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

  environment.systemPackages = with pkgs; [ update-systemd-resolved ];

  system.stateVersion = "23.11";

}

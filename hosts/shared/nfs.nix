{ lib, config, ... }:
let
  options = [
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
  ];
in
{
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  # fileSystems."/mnt/media" = {
  #   device = "truenas.marnas.sh:/mnt/Pool1/media";
  #   options = options;
  #   fsType = "nfs";
  # };

  fileSystems."/mnt/media/music" = {
    device = "truenas.marnas.sh:/mnt/Pool0/music";
    options = options;
    fsType = "nfs";
  };

  fileSystems."/mnt/Games" = lib.mkIf (config.networking.hostName == "nixos") {
    device = "truenas.marnas.sh:/mnt/Pool0/Games";
    options = options;
    fsType = "nfs";
  };

}

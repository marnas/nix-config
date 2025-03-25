{ lib, config, ... }: {
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  fileSystems."/mnt/media" = {
    device = "truenas.marnas.sh:/mnt/Pool1/media";
    options = [ "x-systemd.automount" "x-systemd.idle-timeout=600" ];
    fsType = "nfs";
  };

  fileSystems."/mnt/backup" = lib.mkIf (config.networking.hostName == "nixos") {
    device = "truenas.marnas.sh:/mnt/Pool0/backup";
    options = [ "x-systemd.automount" "x-systemd.idle-timeout=600" ];
    fsType = "nfs";
  };

  fileSystems."/mnt/Games" = lib.mkIf (config.networking.hostName == "nixos") {
    device = "truenas.marnas.sh:/mnt/Pool0/Games";
    options = [ "x-systemd.automount" "x-systemd.idle-timeout=600" ];
    fsType = "nfs";
  };

}

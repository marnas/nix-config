{ ... }:
{

  imports = [ ../shared/nfs.nix ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e105daca-11af-4c6f-a56c-b04df968ac88";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5CCB-A8F5";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

}

{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ../shared/nfs.nix ];

  boot = {
    initrd.availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    # Bootloader.
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/283606f9-4077-4bad-b69c-697eed6fbc2f";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/53d8c90c-30d8-4785-a5cf-517f74e90a0c"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens18.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

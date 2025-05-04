{ pkgs, config, lib, modulesPath, ... }:

{
  imports = [
    ./filesystems.nix
    ./udev-rules.nix

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "amdgpu" ];
    };
    extraModulePackages = [ ];

    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # NixOS configuration for Star Citizen requirements
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    amdgpu.amdvlk = {
      enable = false;
      support32Bit.enable = false;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };

    xpadneo.enable = true; # Enable support for Xbox controllers

    new-lg4ff.enable = true; # Enable support for Logitech driving wheels

    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];
      # To allow tailscale exit nodes without losing internet access.
      checkReversePath = "loose";
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

{ pkgs, ... }:
{
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "wootings_udev";
      text = ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="31e3", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="31e3", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-wootings.rules";
    })

    (pkgs.writeTextFile {
      name = "finalmouse_udev";
      text = ''
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="361d", ATTR{idProduct}=="0100", MODE="0666"
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="361d", ATTR{idProduct}=="0101", MODE="0666"
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="361d", ATTR{idProduct}=="0102", MODE="0666"
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="361d", ATTR{idProduct}=="0103", MODE="0666"
        SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="361d", ATTR{idProduct}=="0111", MODE="0666"
          
        KERNEL=="hidraw*", ATTRS{idVendor}=="361d", ATTRS{idProduct}=="0100", MODE="0666"
        KERNEL=="hidraw*", ATTRS{idVendor}=="361d", ATTRS{idProduct}=="0101", MODE="0666"
        KERNEL=="hidraw*", ATTRS{idVendor}=="361d", ATTRS{idProduct}=="0102", MODE="0666"
      '';
      destination = "/etc/udev/rules.d/99-finalmouse.rules";
    })

    (pkgs.writeTextFile {
      name = "fpv_udev";
      text = ''
        # STM32 DFU bootloader (EdgeTX flashing, Betaflight DFU)
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"
        # STM32 virtual COM port (radio VCP, Betaflight Configurator, ELRS passthrough).
        # Tag both the USB device and the tty node so the user gets an ACL on /dev/ttyACM*.
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", TAG+="uaccess"
        SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/70-fpv.rules";
    })
  ];
}

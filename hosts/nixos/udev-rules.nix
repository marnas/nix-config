{ pkgs, ... }: {
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
    ];
}

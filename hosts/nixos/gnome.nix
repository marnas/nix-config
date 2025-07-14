{ pkgs, ... }: {
  services = {
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    cheese # webcam tool
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    evince # document viewer
    totem # video player
    nautilus
    gnome-text-editor
    gnome-calendar
    gnome-system-monitor
    yelp
    gnome-music
    gnome-maps
    gnome-clocks
    gnome-weather
    gnome-contacts
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  # Setting the right resolution and refresh rate for GDM
  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${
      pkgs.writeText "gdm-monitors.xml" ''
        <!-- this should all be copied from your ~/.config/monitors.xml -->
        <monitors version="2">
          <configuration>
            <layoutmode>physical</layoutmode>
            <logicalmonitor>
              <x>0</x>
              <y>0</y>
              <scale>1</scale>
              <primary>yes</primary>
              <monitor>
                <monitorspec>
                  <connector>DP-1</connector>
                  <vendor>DEL</vendor>
                  <product>AW2725DF</product>
                  <serial>8ZK1ZZ3</serial>
                </monitorspec>
                <mode>
                  <width>2560</width>
                  <height>1440</height>
                  <rate>143.912</rate>
                </mode>
              </monitor>
            </logicalmonitor>
            <logicalmonitor>
              <x>2560</x>
              <y>0</y>
              <scale>1</scale>
              <monitor>
                <monitorspec>
                  <connector>DP-2</connector>
                  <vendor>DEL</vendor>
                  <product>AW2725DF</product>
                  <serial>DFL1ZZ3</serial>
                </monitorspec>
                <mode>
                  <width>2560</width>
                  <height>1440</height>
                  <rate>359.979</rate>
                </mode>
              </monitor>
            </logicalmonitor>
            <disabled>
              <monitorspec>
                <connector>HDMI-1</connector>
                <vendor>GSM</vendor>
                <product>LG TV SSCR2</product>
                <serial>0x01010101</serial>
              </monitorspec>
            </disabled>
          </configuration>
        </monitors>
      ''
    }"
  ];
}

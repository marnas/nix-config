{ pkgs, lib, ... }:
{
  services = {
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    gnome = {
      core-apps.enable = false;
      # Disable accessibility services (Orca screen reader)
      at-spi2-core.enable = lib.mkForce false;
    };
  };

  environment.gnome.excludePackages = (
    with pkgs;
    [
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
      orca # screen reader
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]
  );

  # Setting the right resolution and refresh rate for GDM
  # GNOME 49+ uses dynamic users with seat-specific config path
  systemd.tmpfiles.rules = [
    "L+ /var/lib/gdm/seat0/config/monitors.xml - - - - ${./monitors.xml}"
  ];
}

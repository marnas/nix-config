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

  # GDM 50 runs the greeter as a dynamic user (gdm-greeter-N) with HOME=/run/gdm/home/...,
  # but sets XDG_CONFIG_HOME=/run/gdm/.config for it. Mutter loads monitors.xml from
  # XDG_CONFIG_HOME only — not XDG_CONFIG_DIRS — so the file must live at
  # /run/gdm/.config/monitors.xml. /run/gdm is tmpfs, so re-create the dir and link on boot.
  systemd.tmpfiles.rules = [
    "d /run/gdm/.config 0755 gdm gdm -"
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];
}

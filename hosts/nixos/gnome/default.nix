{ pkgs, lib, ... }:
{
  # Pin GDM greeter stack to nixos-25.11 (gdm 49.2, gnome-shell 49.4). GDM 50 silently
  # ignores monitors.xml at /var/lib/gdm/seat0/config; revert until upstream sorts it.
  # mutter rides in via gnome-shell's closure. mkAfter so prev.stable (from stable-packages
  # overlay in hosts/shared/nix.nix) is populated before this runs.
  nixpkgs.overlays = lib.mkAfter [
    (_final: prev: { inherit (prev.stable) gdm gnome-session gnome-shell; })
  ];

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

  # GDM 50 sets the greeter's XDG_CONFIG_HOME to /var/lib/gdm/<seat>/config
  # (setup_seat_persist_dirs in gdm-launch-environment.c). Mutter loads monitors.xml
  # only from XDG_CONFIG_HOME — not XDG_CONFIG_DIRS — so the file must land there.
  # The dir is created by GDM itself; we just drop the symlink in.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/gdm/seat0/config/monitors.xml - - - - ${./monitors.xml}"
  ];
}

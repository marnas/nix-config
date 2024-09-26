{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./tofi.nix
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gnome ];
    # configPackages = [ pkgs.hyprland ];
    config.common.default = "*";
  };

  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
    };
    associations.added = {
      # others...
    };
  };

  home.packages = with pkgs; [
    grim
    slurp
    gtk3 # For gtk-launch
    imv
    mimeo
    xwayland
    pulseaudio
    waypipe
    wf-recorder
    wl-clipboard
    wl-mirror
    ydotool

    polkit
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    mesa
    wayland
    wl-clipboard
    meson
    wayland-protocols
    wayland-utils
    wlroots
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    polkit-kde-agent
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "hyprland";
    LIBSEAT_BACKEND = "logind";
  };

}

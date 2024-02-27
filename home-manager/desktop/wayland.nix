{ pkgs, ... }:
{
  imports = [
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    configPackages = [ pkgs.hyprland ];
  };

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    grim
    slurp
    gtk3 # For gtk-launch
    imv
    mimeo
    xwayland
    pulseaudio
    slurp
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
    waybar
    wl-clipboard
    wofi
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
    LIBSEAT_BACKEND = "logind";
  };

}

{ pkgs, ... }: {
  imports = [
    ./hyprland
    ./waybar.nix
    ./tofi.nix
    ./mako.nix
    ./swayidle.nix

  ];

  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gnome
      ];
      # configPackages = [ pkgs.hyprland ];
      config.common.default = "*";
    };

    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = "org.gnome.eog.desktop";
        "image/jpeg" = "org.gnome.eog.desktop";

        "text/html" = "firefox.desktop";
        "text/xml" = [ "firefox.desktop" ];
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
      associations.added = {
        # others...
      };
    };
  };

  home = {
    packages = with pkgs; [
      # grim
      gtk3
      imv
      libnotify
      libsForQt5.qt5.qtwayland
      mimeo
      mesa
      meson
      qt6.qtwayland
      # slurp
      wayland
      wayland-protocols
      wayland-utils
      waypipe
      wl-clipboard
      wl-mirror
      wf-recorder
      wlroots
      xdg-desktop-portal-gtk
      xwayland
      ydotool
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland";
      XDG_CURRENT_DESKTOP = "hyprland";
      LIBSEAT_BACKEND = "logind";
    };
  };
}

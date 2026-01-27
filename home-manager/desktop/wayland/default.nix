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
      ];
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

				"audio/flac" = "vlc.desktop";
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
      xwayland
      ydotool
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_QPA_PLATFORM = "wayland";
      LIBSEAT_BACKEND = "logind";
    };
  };
}

{ pkgs, ... }:
{
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

    # fcitx5 writes its own ~/.config/fcitx5/config; force-manage just the
    # trigger keys to drop the default Control+space (now handled by the
    # Hyprland keybind so the waybar indicator updates event-driven, see
    # hyprland/binds.nix). All other fcitx5 options keep their compiled
    # defaults — only this list is overridden.
    configFile."fcitx5/config" = {
      force = true;
      text = ''
        [Hotkey/TriggerKeys]
        0=Zenkaku_Hankaku
        1=Hangul
      '';
    };
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
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      NIX_PROFILES = "/home/marnas/.nix-profile /nix/var/nix/profiles/default";
    };
  };
}

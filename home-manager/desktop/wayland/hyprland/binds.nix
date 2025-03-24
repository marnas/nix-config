{ config, ... }: {
  wayland.windowManager.hyprland.settings = {
    bindm = [ "SUPER,mouse:272,movewindow" "SUPER,mouse:273,resizewindow" ];
    bind = let
      # swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      # playerctl = "${config.services.playerctld.package}/bin/playerctl";
      # playerctld = "${config.services.playerctld.package}/bin/playerctld";
      # makoctl = "${config.services.mako.package}/bin/makoctl";
      #
      # grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
      # tesseract = "${pkgs.tesseract}/bin/tesseract";
      #
      # tly = "${pkgs.tly}/bin/tly";
      # gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
      # notify-send = "${pkgs.libnotify}/bin/notify-send";
      #
      terminal = config.home.sessionVariables.TERMINAL;
      browser = "zen";
      passmanager = "1password";
      mod = "SUPER";
      menu = "tofi-drun --drun-launch=true";
      # editor = defaultApp "text/plain";
    in [
      # Program bindings
      "${mod},Return,exec,${terminal}"
      "${mod},b,exec,${browser}"
      "${mod},o,exec,${passmanager}"
      "${mod}, Q, killactive,"
      "${mod}, V, togglefloating,"
      "${mod}, SPACE, exec, ${menu}"
      "${mod} CTRL, E, exit,"
      "${mod}, P, pseudo," # dwindle
      "${mod}, J, togglesplit, " # dwindle
      "${mod}, F, fullscreen, 0"
      "${mod}, E, focusmonitor, +1"
      "${mod} SHIFT, E, movewindow, mon:+1"

      # Volume
      ",XF86AudioRaiseVolume,exec,volumectl -u up"
      ",XF86AudioLowerVolume,exec,volumectl -u down"
      ",XF86AudioMute,exec,volumectl toggle-mute"
      # # Screenshotting
      ''${mod} CTRL, p, exec, grim -g "$(slurp -d)" - | wl-copy -t image/png''
      # ",Print,exec,${grimblast} --notify --freeze copy output"
      # "SUPER,Print,exec,${grimblast} --notify --freeze copy area"

      # Move focus with mod + arrow keys
      "${mod}, left, movefocus, l"
      "${mod}, right, movefocus, r"
      "${mod}, up, movefocus, u"
      "${mod}, down, movefocus, d"
      # Colemak support
      "${mod}, m, movefocus, l"
      "${mod}, i, movefocus, r"
      "${mod}, e, movefocus, u"
      "${mod}, n, movefocus, d"

      # Example special workspace (scratchpad)col.sha
      "${mod}, S, togglespecialworkspace, magic"
      "${mod} SHIFT, S, movetoworkspace, special:magic"

      # Workspaces
      "${mod}, 1, split-workspace, 1"
      "${mod}, 2, split-workspace, 2"
      "${mod}, 3, split-workspace, 3"
      "${mod}, 4, split-workspace, 4"
      "${mod}, 5, split-workspace, 5"

      "${mod} SHIFT, 1, split-movetoworkspace, 1"
      "${mod} SHIFT, 2, split-movetoworkspace, 2"
      "${mod} SHIFT, 3, split-movetoworkspace, 3"
      "${mod} SHIFT, 4, split-movetoworkspace, 4"
      "${mod} SHIFT, 5, split-movetoworkspace, 5"
    ];
  };
}

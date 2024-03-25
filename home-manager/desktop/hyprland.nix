{ config, lib, pkgs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    # plugins = [
    #   inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    # ];

    settings = {
      monitor = [
        "DP-1,2560x1440@75,0x0,1"
        "DP-2,2560x1440@75,2560x0,1"
      ];
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;

        # layout = dwindle;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };


      # master = {
      #   new_is_master = false;
      # };

      # Execute your favorite apps at launch
      exec-once = [
        "waybar"
        "swaync"
        "1password --silent"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";

        follow_mouse = true;

        touchpad = {
          natural_scroll = true;
        };

        sensitivity = 0;
      };

      decoration = {
        active_opacity = 0.97;
        inactive_opacity = 0.77;
        fullscreen_opacity = 1.0;
        rounding = 2;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
        "col.shadow" = "0x44000000";
        "col.shadow_inactive" = "0x66000000";
      };

      exec = [
        "${pkgs.swaybg}/bin/swaybg -i /home/marnas/Pictures/Mountains.png --mode fill"
      ];

      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      gestures = {
        workspace_swipe = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };


      bindm = [
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow"
      ];
      bind =
        let
          # swaylock = "${config.programs.swaylock.package}/bin/swaylock";
          # playerctl = "${config.services.playerctld.package}/bin/playerctl";
          # playerctld = "${config.services.playerctld.package}/bin/playerctld";
          # makoctl = "${config.services.mako.package}/bin/makoctl";
          # wofi = "${config.programs.wofi.package}/bin/wofi";
          # pass-wofi = "${pkgs.pass-wofi.override {
          #   pass = config.programs.password-store.package;
          # }}/bin/pass-wofi";
          #
          # grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
          # tesseract = "${pkgs.tesseract}/bin/tesseract";
          #
          # tly = "${pkgs.tly}/bin/tly";
          # gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
          # notify-send = "${pkgs.libnotify}/bin/notify-send";
          #
          terminal = config.home.sessionVariables.TERMINAL;
          browser = "firefox";
          mod = "SUPER";
          menu = "wofi --show drun";
          # editor = defaultApp "text/plain";
        in
        [
          # Program bindings
          "${mod},Return,exec,${terminal}"
          "${mod},b,exec,${browser}"
          "${mod}, Q, killactive,"
          "${mod}, V, togglefloating,"
          "${mod}, SPACE, exec, ${menu}"
          "${mod} CTRL, E, exit,"
          "${mod}, P, pseudo," # dwindle
          "${mod}, J, togglesplit, " # dwindle
          "${mod}, F, fullscreen, 0"
          "${mod}, E, focusmonitor, +1"
          "${mod} SHIFT, E, split-changemonitor, next"

          # Volume
          ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          # # Screenshotting
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

          # Example special workspace (scratchpad)
          "${mod}, S, togglespecialworkspace, magic"
          "${mod} SHIFT, S, movetoworkspace, special:magic"

          "${mod} CTRL, p, exec, grim -g \"$(slurp -d)\" - | wl-copy -t image/png"

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


    extraConfig = ''
      general {
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
      }

      misc {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
      }
    '';
  };

}


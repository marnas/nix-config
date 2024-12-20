{ config, pkgs, inputs, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      # inputs.hyprsplit.packages.${pkgs.system}.hyprsplit
    ];

    settings = {
      monitor = [ "DP-1,2560x1440@360,0x0,1" "DP-2,2560x1440@360,2560x0,1" ];
      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;

        # layout = dwindle;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      # master = {
      #   new_is_master = false;
      # };

      windowrulev2 = [ "idleinhibit fullscreen, fullscreen:1" ];

      # Execute your favorite apps at launch
      exec-once = [ "1password --silent" ];

      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";

        follow_mouse = true;

        touchpad = { natural_scroll = true; };

        sensitivity = "-0.8";
        accel_profile = "adaptive";
      };

      decoration = {
        active_opacity = 0.97;
        inactive_opacity = 0.97;
        # inactive_opacity = 0.77;
        fullscreen_opacity = 1.0;
        rounding = 2;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 12;
          color = "0x44000000";
          color_inactive = "0x66000000";
          offset = "3 3";
        };
      };

      exec = [
        "${pkgs.swaybg}/bin/swaybg -o DP-1 -i /home/marnas/Pictures/Mountains.png --mode fill"
        "${pkgs.swaybg}/bin/swaybg -o DP-2 -i /home/marnas/Pictures/Neon_Japanese.png --mode fill"
      ];

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      misc = {
        focus_on_activate = true;
        force_default_wallpaper = 0;
      };

      gestures = { workspace_swipe = true; };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      plugin = {
        # hyprsplit = {
        #   num_workspaces = 5;
        #   # enable_persistent_workspaces = false;
        # };
        split-monitor-workspaces = {
          count = 5;
          enable_persistent_workspaces = 0;
        };
      };

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
        # ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        # ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
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
  };

}


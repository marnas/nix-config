{ inputs
, outputs
, config
, pkgs
, ...
}: {

  imports = [
    ./cli
    ./desktop
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "marnas";
    homeDirectory = "/home/marnas";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    teams-for-linux
    postman
    orca-slicer
    telegram-desktop
    discord
    whatsapp-for-linux
    steam
    lutris
    plexamp
    gimp
    nextcloud-client
    gnome.eog
    lens
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CURRENT_DESKTOP = "hyprland";
  };

  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.name = "macOS-BigSur";
  home.pointerCursor.package = pkgs.apple-cursor;
  home.pointerCursor.size = 30;

  gtk = {
    enable = true;
    cursorTheme = {
      name = "macOS-BigSur";
    }; # enable = true;
    # font.name = "TeX Gyre Adventor 10";
    # theme = {
    #   name = "Juno";
    #   package = pkgs.juno-theme;
    # };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    # plugins = [
    #   inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    # ];
    extraConfig = ''
            # See https://wiki.hyprland.org/Configuring/Monitors/
            monitor=,preferred,auto,auto
      
      	  # Execute your favorite apps at launch
            exec-once = waybar
            exec-once = swaync
            exec-once = 1password --silent

            # Source a file (multi-file configs)
            # source = ~/.config/hypr/myColors.conf

            # Set programs that you use
            $terminal = alacritty
            $fileManager = dolphin
            $menu = wofi --show drun

            # Some default env vars.
            env = XCURSOR_SIZE,14
            env = QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that

            # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
            input {
                kb_layout = us
                kb_variant = altgr-intl
                kb_model =
                kb_options =
                kb_rules =

                follow_mouse = 1

                touchpad {
                    natural_scroll = yes
                }

                sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
            }

            general {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more

                gaps_in = 5
                gaps_out = 20
                border_size = 2
                col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
                col.inactive_border = rgba(595959aa)

                layout = dwindle

                # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
                allow_tearing = false
            }

            decoration {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more

                rounding = 2

                blur {
                    enabled = true
                    size = 3
                    passes = 1
                }

                drop_shadow = yes
                shadow_range = 4
                shadow_render_power = 3
                col.shadow = rgba(1a1a1aee)
            }

            animations {
                enabled = yes

                # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

                bezier = myBezier, 0.05, 0.9, 0.1, 1.05

                animation = windows, 1, 7, myBezier
                animation = windowsOut, 1, 7, default, popin 80%
                animation = border, 1, 10, default
                animation = borderangle, 1, 8, default
                animation = fade, 1, 7, default
                animation = workspaces, 1, 6, default
            }

            dwindle {
                # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
                pseudotile = yes # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
                preserve_split = yes # you probably want this
            }

            master {
                # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
                new_is_master = false
            }

            gestures {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                workspace_swipe = on
            }

            misc {
                # See https://wiki.hyprland.org/Configuring/Variables/ for more
                force_default_wallpaper = -1 # Set to 0 to disable the anime mascot wallpapers
            }

            # Example per-device config
            # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
            #device:epic-mouse-v1 {
            #    sensitivity = -0.5
            #}

            # Example windowrule v1
            # windowrule = float, ^(kitty)$
            # Example windowrule v2
            # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
            # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
            #windowrulev2 = nomaximizerequest, class:.* # You'll probably like this.


            # See https://wiki.hyprland.org/Configuring/Keywords/ for more
            $mod = SUPER

            # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
            bind = $mod, RETURN, exec, $terminal
            bind = $mod, Q, killactive, 
            bind = $mod, V, togglefloating, 
            bind = $mod, SPACE, exec, $menu
            bind = $mod CTRL, E, exit,
            bind = $mod, P, pseudo, # dwindle
            bind = $mod, J, togglesplit, # dwindle
            bind = $mod, F, fullscreen, 0
            bind = $mod, E, focusmonitor, +1
            bind = $mod SHIFT, E, split-changemonitor, next

            # Move focus with mod + arrow keys
            bind = $mod, left, movefocus, l
            bind = $mod, right, movefocus, r
            bind = $mod, up, movefocus, u
            bind = $mod, down, movefocus, d

            bind = $mod, 1, split-workspace, 1
            bind = $mod, 2, split-workspace, 2
            bind = $mod, 3, split-workspace, 3
            bind = $mod, 4, split-workspace, 4
            bind = $mod, 5, split-workspace, 5

            bind = $mod SHIFT, 1, split-movetoworkspace, 1
            bind = $mod SHIFT, 2, split-movetoworkspace, 2
            bind = $mod SHIFT, 3, split-movetoworkspace, 3
            bind = $mod SHIFT, 4, split-movetoworkspace, 4
            bind = $mod SHIFT, 5, split-movetoworkspace, 5

            # Example special workspace (scratchpad)
            bind = $mod, S, togglespecialworkspace, magic
            bind = $mod SHIFT, S, movetoworkspace, special:magic

            # Scroll through existing workspaces with mod + scroll
            bind = $mod, mouse_down, workspace, e+1
            bind = $mod, mouse_up, workspace, e-1

            # Move/resize windows with mod + LMB/RMB and dragging
            bindm = $mod, mouse:272, movewindow
            bindm = $mod, mouse:273, resizewindow

            bind = $mod CTRL, p, exec, grim -g "$(slurp -d)" - | wl-copy -t image/png

            bind =, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
            bind =, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            bind =, XF86AudioMute, exec , wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

    '';
  };


  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}

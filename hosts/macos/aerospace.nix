{ pkgs, ... }: let
  aerospaceWs = pkgs.writeShellApplication {
    name = "aerospace-ws";
    runtimeInputs = [ pkgs.aerospace ];
    text = ''
      n="$1"
      action="''${2:-focus}"
      focused=$(aerospace list-monitors --focused | awk '{print $1}')
      if [ "$focused" = "1" ]; then
        target="$n"
      else
        target=$((n + 5))
      fi
      if [ "$action" = "move" ]; then
        aerospace move-node-to-workspace --focus-follows-window "$target"
      else
        aerospace workspace "$target"
      fi
    '';
  };
  ws = "${aerospaceWs}/bin/aerospace-ws";
in {
  services.aerospace = {
    enable = true;

    settings = {
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # Cursor also follows focus changes within a workspace (matches Hyprland's
      # focus-follows-mouse feel even closer). Try if focus changes feel disconnected.
      # on-focus-changed = [ "move-mouse window-lazy-center" ];

      # Spiral / dwindle-style tiling. Without these, AeroSpace doesn't
      # auto-alternate split orientation, so nested splits all go the same way.
      # Enabling both flattens redundant containers and forces nested ones to
      # alternate horizontal/vertical, matching Hyprland's dwindle layout.
      # enable-normalization-flatten-containers = true;
      # enable-normalization-opposite-orientation-for-nested-containers = true;

      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
        inner.horizontal = 8;
        inner.vertical = 8;
      };

      mode.main.binding = {
        cmd-h = "focus left";
        cmd-j = "focus down";
        cmd-k = "focus up";
        cmd-l = "focus right";

        cmd-shift-h = "move left";
        cmd-shift-j = "move down";
        cmd-shift-k = "move up";
        cmd-shift-l = "move right";

        cmd-left = "focus left";
        cmd-down = "focus down";
        cmd-up = "focus up";
        cmd-right = "focus right";

        cmd-shift-left = "move left";
        cmd-shift-down = "move down";
        cmd-shift-up = "move up";
        cmd-shift-right = "move right";

        cmd-e = "focus-monitor --wrap-around next";
        cmd-shift-e = "move-node-to-monitor --wrap-around --focus-follows-window next";

        cmd-1 = "exec-and-forget ${ws} 1";
        cmd-2 = "exec-and-forget ${ws} 2";
        cmd-3 = "exec-and-forget ${ws} 3";
        cmd-4 = "exec-and-forget ${ws} 4";
        cmd-5 = "exec-and-forget ${ws} 5";

        cmd-shift-1 = "exec-and-forget ${ws} 1 move";
        cmd-shift-2 = "exec-and-forget ${ws} 2 move";
        cmd-shift-3 = "exec-and-forget ${ws} 3 move";
        cmd-shift-4 = "exec-and-forget ${ws} 4 move";
        cmd-shift-5 = "exec-and-forget ${ws} 5 move";

        cmd-shift-f = "fullscreen";

        cmd-shift-r = "mode resize";
      };

      # Use positional indices (left-to-right per macOS Displays > Arrange),
      # not "main"/"secondary" — those follow macOS's primary-display flag
      # and drift out of sync with the aerospace-ws helper, which keys off
      # the focused monitor's index.
      workspace-to-monitor-force-assignment = {
        "1" = 1;
        "2" = 1;
        "3" = 1;
        "4" = 1;
        "5" = 1;
        "6" = 2;
        "7" = 2;
        "8" = 2;
        "9" = 2;
        "10" = 2;
      };

      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";

        # Evenly distribute space among sibling windows in the current container.
        # b = "balance-sizes";

        # Flatten the workspace's container tree (clears weird nesting from
        # repeated moves) and exit resize mode.
        # r = [ "flatten-workspace-tree" "mode main" ];

        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}

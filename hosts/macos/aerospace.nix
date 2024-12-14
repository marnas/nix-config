{ ... }: {
  services.aerospace = {
    enable = true;

    settings = {
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
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

        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";
        cmd-0 = "workspace 10";

        cmd-shift-1 = "move-node-to-workspace 1 --focus-follows-window";
        cmd-shift-2 = "move-node-to-workspace 2 --focus-follows-window";
        cmd-shift-3 = "move-node-to-workspace 3 --focus-follows-window";
        cmd-shift-4 = "move-node-to-workspace 4 --focus-follows-window";
        cmd-shift-5 = "move-node-to-workspace 5 --focus-follows-window";
        cmd-shift-6 = "move-node-to-workspace 6 --focus-follows-window";
        cmd-shift-7 = "move-node-to-workspace 7 --focus-follows-window";
        cmd-shift-8 = "move-node-to-workspace 8 --focus-follows-window";
        cmd-shift-9 = "move-node-to-workspace 9 --focus-follows-window";
        cmd-shift-0 = "move-node-to-workspace 10 --focus-follows-window";

        cmd-shift-f = "fullscreen";

        cmd-r = "mode resize";
      };

      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}

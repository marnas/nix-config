{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 10;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs;
      [
        {
          plugin = tilish-colemak;
          extraConfig = ''
            set -g @tilish-default 'main-vertical'
            set -g @tilish-colemak 'on'
            set -g @tilish-navigator 'on'
          '';
        }
        tmuxPlugins.better-mouse-mode
      ];
    extraConfig = ''
      bind -n S-Up resize-pane -U 5
      bind -n S-Down resize-pane -D 5
      bind -n S-Left resize-pane -L 5
      bind -n S-Right resize-pane -R 5
    '';
  };
}

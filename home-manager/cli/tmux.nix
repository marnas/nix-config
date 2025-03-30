{ pkgs, vars, ... }: {
  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 10;
    baseIndex = 1;
    keyMode = "vi";
    sensibleOnTop = if (vars.hostname == "macos") then false else true;
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      {
        plugin = tilish-colemak;
        extraConfig = ''
          set -g @tilish-default 'main-vertical'
          set -g @tilish-colemak 'on'
          set -g @tilish-navigator 'on'
        '';
      }
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-navigator
    ];
    extraConfig = ''
      bind -n S-Up resize-pane -U 5
      bind -n S-Down resize-pane -D 5
      bind -n S-Left resize-pane -L 5
      bind -n S-Right resize-pane -R 5

      set-option -g focus-events on
      set-option -a terminal-features 'alacritty:RGB'

      # new shortcut to clean terminal
      bind -n C-p send-keys C-l
        
      # to forward Ctrl-Tab
      # set -g extended-keys on
    '';
  };
}

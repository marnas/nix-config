{ pkgs, vars, ... }:
let
  terminal =
    if (vars.hostname == "macos") then "xterm-256color" else "alacritty";
in {
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
      # Nord color scheme (matches the agent-indicator demo aesthetic).
      tmuxPlugins.nord
      {
        plugin = tmux-agent-indicator;
        extraConfig = ''
          # No full-width status-bar flash on transitions; the pane border +
          # animated indicator is signal enough.
          set -g @agent-indicator-notification-enabled off
          # Spinner on the @agent_indicator token while an agent is running.
          set -g @agent-indicator-animation-enabled on

          # Status format MUST be set here, before agent-indicator loads, so its
          # token-substitution pass rewrites #{agent_*} into the script calls.
          # If set inside minimal-tmux-status's extraConfig it lands too late.
          set -g @minimal-tmux-status-right '#{agent_session_dots} #{agent_indicator} %H:%M'
        '';
      }
      # Minimal status bar that consumes @agent_indicator / @agent_session_dots.
      # Loaded after agent-indicator so token substitution has already happened.
      {
        plugin = tmuxPlugins.minimal-tmux-status;
        extraConfig = ''
          set -g @minimal-tmux-justify 'left'
        '';
      }
    ];
    extraConfig = ''
      bind -n S-Up resize-pane -U 5
      bind -n S-Down resize-pane -D 5
      bind -n S-Left resize-pane -L 5
      bind -n S-Right resize-pane -R 5

      set-option -g focus-events on

      set-option -ga terminal-overrides ",${terminal}:Tc"

      # Window names reflect the active pane's cwd basename (e.g. ".dotfiles")
      # instead of the current command. allow-rename off blocks OSC 0/2 escapes
      # so TUIs like Claude can't freeze the name by setting a title.
      set -g allow-rename off
      set -g automatic-rename-format '#{b:pane_current_path}'

      # Pane borders: nord palette, heavy lines, bold red active border.
      set -g pane-border-style 'fg=#4C566A'
      set -g pane-active-border-style 'fg=#BF616A,bold'
      set -g pane-border-lines heavy
      set -g pane-border-indicators arrows

      # status-right is overridden by minimal-tmux-status via
      # @minimal-tmux-status-right (see plugin block below).

      # new shortcut to clean terminal
      bind -n C-p send-keys C-l
        
      # to forward Ctrl-Tab
      # set -g extended-keys on
    '';
  };
}

{ pkgs, ... }:
let
  # Context-usage widget with threshold colors (ccstatusline has no native
  # value-based coloring). Reads Claude Code's statusline JSON on stdin and emits
  # the percentage wrapped in a truecolor escape. Wired in as a `custom-command`
  # widget with preserveColors.
  #
  # The percentage is measured against the *usable* budget (0.8 × window), i.e.
  # the auto-compact point — so 100% means "Claude is about to compact" and the
  # number matches Claude's own context indicator. Token math mirrors
  # ccstatusline's context-percentage-usable widget: input + cache (excludes
  # output), divided by 0.8 × context_window_size.
  #
  # Thresholds (% toward auto-compact), tuned for cost — act well before Claude:
  #   green  <50%  fine
  #   yellow 50-74% consider compacting / fresh context at the next break
  #   red    >=75%  recompact now, before the window bloats every turn
  ctxColor = pkgs.writeShellApplication {
    name = "ccstatusline-ctx-color";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      json=$(cat)
      pct=$(printf '%s' "$json" | jq -r '
        .context_window as $cw
        | if $cw == null then empty
          else
            (($cw.context_window_size // 0) * 0.8) as $usable
            | ($cw.current_usage) as $u
            | (if ($u|type) == "number" then $u
               elif ($u|type) == "object" then
                 (($u.input_tokens//0)+($u.cache_creation_input_tokens//0)+($u.cache_read_input_tokens//0))
               else null end) as $used
            | if $usable > 0 and $used != null then ([$used/$usable*100, 100] | min) else empty end
          end | floor')
      [ -z "$pct" ] && exit 0
      if   [ "$pct" -lt 50 ]; then c="169;220;118"   # green  #a9dc76 — fine
      elif [ "$pct" -lt 75 ]; then c="252;152;103"   # orange #fc9867 — consider compacting
      else                         c="255;97;136"    # red    #ff6188 — recompact now
      fi
      printf '\033[38;2;%smCtx: %s%%\033[39m' "$c" "$pct"
    '';
  };

  # ccstatusline reads ~/.config/ccstatusline/settings.json. Managing it here
  # makes the statusline config version-controlled and synced across hosts.
  # Trade-off: the file becomes a read-only store symlink, so the `ccstatusline`
  # TUI can no longer save changes — edit this attrset instead.
  #
  # Colors are Monokai Pro (matching nvim), in ccstatusline's "hex:RRGGBB" form;
  # colorLevel 3 (truecolor) is required for them to render.
  settings = {
    version = 3;
    lines = [
      [
        {
          id = "1";
          type = "model";
          color = "hex:78dce8"; # cyan — identity/accent
        }
        {
          id = "2";
          type = "separator";
          color = "hex:727072"; # comment grey
        }
        {
          id = "3";
          type = "custom-command";
          commandPath = "${ctxColor}/bin/ccstatusline-ctx-color";
          preserveColors = true; # keep the escape codes the script emits
          timeout = 1000;
        }
        # session-usage + reset-timer (the account-level 5h-block metrics,
        # identical across every pane) live in the tmux status bar instead —
        # see pkgs/claude-usage-tmux and tmux.nix. This line keeps only the
        # per-conversation widgets: model and context %.
      ]
      [ ]
      [ ]
    ];
    flexMode = "full-minus-40";
    compactThreshold = 60;
    colorLevel = 3;
    inheritSeparatorColors = false;
    globalBold = false;
    gitCacheTtlSeconds = 5;
    minimalistMode = false;
    powerline = {
      enabled = false;
      separators = [ "" ];
      separatorInvertBackground = [ false ];
      startCaps = [ ];
      endCaps = [ ];
      autoAlign = false;
      continueThemeAcrossLines = false;
    };
  };
in
{
  home.packages = [ pkgs.ccstatusline ];

  xdg.configFile."ccstatusline/settings.json".source =
    (pkgs.formats.json { }).generate "ccstatusline-settings.json"
      settings;
}

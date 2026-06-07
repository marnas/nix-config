{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Keep the account-level Claude usage cache warm for the tmux status widget.
  #
  # The tmux render-path widget (pkgs/claude-usage-tmux) only *reads* the cache
  # at ~/.cache/ccstatusline/usage.json and formats the 5h-block session-usage %
  # + reset countdown. The data behind it comes from ccstatusline's OAuth usage
  # API (api.anthropic.com/api/oauth/usage), cached on disk with a 180s TTL. A
  # *live* Claude session populates that cache for free from the `rate_limits`
  # field of the statusline stdin JSON; nothing else refreshes it when Claude is
  # closed (or tmux isn't open), so the widget could go stale.
  #
  # This timer decouples freshness from Claude/tmux: run the ccstatusline-backed
  # fetcher (pkgs/claude-usage-refresh) on its own cadence to repopulate
  # usage.json. The 4-min interval is deliberately > ccstatusline's 180s TTL, so
  # every fire is past the cache window and performs a real refetch — bounding
  # staleness at ~4 min even when tmux is closed and Claude has never been opened.
  warmCmd = "${pkgs.claude-usage-refresh}/bin/claude-usage-refresh";
in
{
  systemd.user = lib.mkIf pkgs.stdenv.isLinux {
    services.claude-usage-cache = {
      Unit = {
        Description = "Warm the Claude usage cache for the tmux status widget";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = warmCmd;
        StandardOutput = "null";
      };
    };
    timers.claude-usage-cache = {
      Unit.Description = "Refresh the Claude usage cache every 4 minutes";
      Timer = {
        OnActiveSec = "30s"; # first warm shortly after login/switch
        OnUnitActiveSec = "4min"; # then every 4 min, past the 180s cache TTL
        Persistent = true; # catch up after suspend/resume
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  launchd.agents = lib.mkIf pkgs.stdenv.isDarwin {
    claude-usage-cache = {
      enable = true;
      config = {
        ProgramArguments = [ warmCmd ];
        RunAtLoad = true; # warm immediately on login
        StartInterval = 240; # then every 4 min, past the 180s cache TTL
        StandardOutPath = "/dev/null";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/claude-usage-cache.log";
      };
    };
  };
}

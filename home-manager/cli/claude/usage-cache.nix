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
  # API (api.anthropic.com/api/oauth/usage), cached on disk with a 180s TTL.
  #
  # This timer is the *only* writer of that cache: live Claude sessions never
  # touch it — our statusline config (statusline.nix) has no usage-dependent
  # widgets, so ccstatusline's prefetch skips the usage path entirely, and even
  # with such widgets the stdin `rate_limits` data is used in-memory only, never
  # written to usage.json (verified in ccstatusline 2.2.19 src/utils/usage-fetch
  # + prefetchUsageDataIfNeeded). So usage-API traffic from this machine is a
  # constant ~15 req/h regardless of how many Claude agents are running.
  #
  # The 4-min interval is deliberately > ccstatusline's 180s TTL, so every fire
  # is past the cache window and performs a real refetch — bounding staleness at
  # ~4 min even when tmux is closed and Claude has never been opened. If the API
  # 429s, ccstatusline honors Retry-After (observed: 3600s) via usage.lock and
  # the runs in between are no-ops; the widget shows "stale" until it clears.
  warmCmd = "${pkgs.claude-usage-refresh}/bin/claude-usage-refresh";
in
{
  systemd.user = lib.mkIf pkgs.stdenv.isLinux {
    services.claude-usage-cache = {
      # No network-online.target dependency: that target doesn't exist in the
      # systemd *user* manager, so it was inert. A fetch before network-up just
      # fails quietly and the 4-min timer retries.
      Unit.Description = "Warm the Claude usage cache for the tmux status widget";
      Service = {
        Type = "oneshot";
        ExecStart = warmCmd;
        StandardOutput = "null";
        # Default StandardError=inherit would follow stdout into /dev/null and
        # swallow the staleness warning claude-usage-refresh emits on stderr.
        StandardError = "journal";
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

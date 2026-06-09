{
  writeShellApplication,
  writeText,
  ccstatusline,
}:
let
  # Usage-only ccstatusline config: just the account-level 5-hour block metrics
  # (session %, block reset countdown). Running ccstatusline with this config is
  # what actually hits the OAuth usage API and (re)writes the on-disk cache at
  # ~/.cache/ccstatusline/usage.json; we run it only for that side effect and
  # discard stdout. The cheap tmux render path reads that cache via
  # claude-usage-tmux.
  config = writeText "ccstatusline-usage.json" (
    builtins.toJSON {
      version = 3;
      lines = [
        [
          {
            id = "1";
            type = "session-usage";
          }
          {
            id = "2";
            type = "separator";
          }
          {
            id = "3";
            type = "reset-timer";
          }
        ]
        [ ]
        [ ]
      ];
      colorLevel = 0;
      flexMode = "full-minus-40";
    }
  );
in
# Cache warmer for the Claude usage widget. The session-usage / reset-timer
# metrics come from ccstatusline's OAuth usage API (api.anthropic.com/api/oauth/
# usage), token read from ~/.claude/.credentials.json (Linux) or the keychain
# (macOS). A stub stdin payload is fine — these are account-level metrics, not
# per-session ones. ccstatusline handles its own 180s cache TTL + fetch lock.
writeShellApplication {
  name = "claude-usage-refresh";
  runtimeInputs = [ ccstatusline ];
  text = ''
    cache="$HOME/.cache/ccstatusline/usage.json"
    stub='{"model":{"display_name":"x"},"workspace":{"current_dir":"."},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":0}}}'
    printf '%s' "$stub" | ccstatusline --config ${config} >/dev/null 2>&1 || true

    # ccstatusline keeps serving the last-good cache and self-imposes a backoff
    # lock when the OAuth usage endpoint times out / rate-limits, so a failed
    # fetch is invisible from its exit status. Surface staleness ourselves: if
    # the cache is older than two refresh intervals (~8min), the API has been
    # unreachable and the tmux widget is showing a stale block. stat -c is GNU
    # (Linux), stat -f is BSD (macOS).
    if [ -r "$cache" ]; then
      mtime=$(stat -c %Y "$cache" 2>/dev/null || stat -f %m "$cache" 2>/dev/null || echo 0)
      age=$(( $(date +%s) - mtime ))
      if [ "$age" -gt 480 ]; then
        echo "claude-usage-refresh: usage cache is ''${age}s stale; OAuth usage API unreachable, widget will show 'usage: stale'" >&2
      fi
    fi
  '';
}

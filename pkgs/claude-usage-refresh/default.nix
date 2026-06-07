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
    stub='{"model":{"display_name":"x"},"workspace":{"current_dir":"."},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":0}}}'
    printf '%s' "$stub" | ccstatusline --config ${config} >/dev/null 2>&1 || exit 0
  '';
}

{
  writeShellApplication,
  jq,
}:
# Lightweight render-path widget for tmux's status-right `#(...)`, invoked on
# every status redraw (every status-interval seconds, per client). It only reads
# and formats ccstatusline's usage cache with jq — no Node spawn — so it stays
# cheap at that cadence (~5ms / ~4MB vs ccstatusline's ~190ms / ~99MB).
#
# The cache itself is populated out-of-band by claude-usage-refresh (a systemd
# user timer / launchd agent; see home-manager/cli/claude/usage-cache.nix) and,
# whenever a live Claude session is open, by ccstatusline's own statusline pass.
# This widget is a pure reader: if the cache is missing (e.g. before the first
# refresh after login) it prints nothing.
writeShellApplication {
  name = "claude-usage-tmux";
  runtimeInputs = [ jq ];
  text = ''
    # ccstatusline writes to os.homedir()/.cache (it ignores XDG_CACHE_HOME), so
    # mirror that path exactly rather than using $XDG_CACHE_HOME.
    cache="$HOME/.cache/ccstatusline/usage.json"
    [ -r "$cache" ] || exit 0
    jq -rf ${./reader.jq} "$cache" 2>/dev/null || exit 0
  '';
}

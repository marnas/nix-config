{ pkgs, lib }:
# Desktop notification helper for Claude hooks. Reads the hook JSON payload
# from stdin (Claude Code passes session_id + cwd) to enrich the notification
# with project name and tmux pane location.
pkgs.writeShellApplication {
  name = "claude-notify";
  runtimeInputs = [ pkgs.jq ] ++ lib.optional pkgs.stdenv.isLinux pkgs.libnotify;
  text = ''
    urgency="''${1:-normal}"
    message="''${2:-Notification}"

    payload="$(cat)"
    session_id="$(jq -r '.session_id // empty' <<<"$payload")"
    cwd="$(jq -r '.cwd // empty' <<<"$payload")"
    [ -z "$session_id" ] && exit 0

    project="$(basename "''${cwd:-$PWD}")"

    location=""
    if [ -n "''${TMUX:-}" ] && [ -n "''${TMUX_PANE:-}" ] && command -v tmux >/dev/null 2>&1; then
      location="$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null || true)"
    fi

    label="$project"
    [ -n "$location" ] && label="$project · $location"

    # Sync hint replaces prior notifications from the same session in-place
    # so concurrent finishes from the same Claude don't stack.
    sync_hint="string:x-canonical-private-synchronous:claude-$session_id"
    if command -v notify-send >/dev/null 2>&1; then
      notify-send -a "Claude Code" -u "$urgency" -h "$sync_hint" "$label" "$message"
    elif command -v osascript >/dev/null 2>&1; then
      osascript -e "display notification \"$message\" with title \"Claude Code\" subtitle \"$label\""
    fi
  '';
}

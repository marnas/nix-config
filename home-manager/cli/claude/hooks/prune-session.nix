{ pkgs, lib }:
# Delete Claude transcripts that never received a real user prompt, so empty /
# abandoned sessions don't clutter the --resume picker.
#
# Claude Code has no native "only persist sessions with >=1 prompt" knob; the
# built-in switches (CLAUDE_CODE_SKIP_PROMPT_HISTORY, --no-session-persistence,
# cleanupPeriodDays) are all-or-nothing. This hook fills that gap.
#
# Wired into two events because neither alone is sufficient:
#   - SessionEnd   prunes the just-ended session, but fires asynchronously and
#                  can't block, so a quick /exit may tear the process down before
#                  rm runs (or not fire at all for a no-prompt exit).
#   - SessionStart sweeps leftover promptless siblings at the next launch. It
#                  runs synchronously with no teardown race, so it self-heals
#                  anything SessionEnd missed.
#
# A "real prompt" is a transcript line with type=="user", non-meta, whose
# message.content is a non-empty string that isn't a slash-command wrapper
# (those carry <command-name>/<command-message>/<local-command-stdout> tags).
# Tool results are type=="user" too but use array content, so they don't match.
pkgs.writeShellApplication {
  name = "claude-prune-session";
  runtimeInputs = [
    pkgs.jq
    pkgs.findutils
  ];
  text = ''
    # True if the given transcript contains at least one genuine user prompt.
    has_prompt() {
      [ -f "$1" ] || return 1
      [ "$(jq -s '
        any(.[];
          .type == "user"
          and ((.isMeta // false) | not)
          and (.message.content | type == "string")
          and ((.message.content | gsub("^\\s+|\\s+$"; "")) | length > 0)
          and (.message.content
               | test("<command-name>|<command-message>|<local-command-stdout>")
               | not)
        )
      ' "$1" 2>/dev/null)" = "true" ]
    }

    payload="$(cat)"
    event="$(jq -r '.hook_event_name // empty' <<<"$payload")"
    current="$(jq -r '.transcript_path // empty' <<<"$payload")"
    [ -z "$current" ] && exit 0

    # Safety: only ever touch files inside the Claude projects tree.
    case "$current" in
      *"/.claude/projects/"*) ;;
      *) exit 0 ;;
    esac

    if [ "$event" = "SessionStart" ]; then
      # Sweep siblings, never the session that's starting. The -mmin guard
      # spares a concurrent session that was started but hasn't been typed in
      # yet (its transcript was modified within the last minute).
      dir="$(dirname "$current")"
      while IFS= read -r -d "" f; do
        [ "$f" = "$current" ] && continue
        has_prompt "$f" || rm -f "$f"
      done < <(find "$dir" -maxdepth 1 -name '*.jsonl' -type f -mmin +1 -print0)
    else
      # SessionEnd (or any other event): prune just this transcript.
      has_prompt "$current" || rm -f "$current"
    fi
  '';
}

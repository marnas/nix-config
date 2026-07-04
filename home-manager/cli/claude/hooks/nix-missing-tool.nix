{ pkgs }:
# PostToolUse/PostToolUseFailure hint for Bash: when a command is missing from
# PATH, remind the model this is a Nix machine and the tool is one
# `nix shell nixpkgs#<pkg>` away — instead of letting it pivot to a weaker
# substitute. Two triggers:
#   - the shell reported an unknown command (bash/zsh/fish spellings), in any
#     segment of the command — compound commands can partially succeed, hence
#     the hook is also registered on plain PostToolUse;
#   - a PATH probe (`which foo`, `command -v foo`, `type foo`) failed.
# Emits additionalContext next to the tool result; stays silent otherwise.
pkgs.writeShellApplication {
  name = "claude-nix-hint";
  runtimeInputs = [
    pkgs.jq
    pkgs.gnugrep
  ];
  text = ''
    payload="$(cat)"
    event="$(jq -r '.hook_event_name // "PostToolUse"' <<<"$payload")"
    cmd="$(jq -r '.tool_input.command // empty' <<<"$payload")"
    [ -z "$cmd" ] && exit 0
    # PostToolUse carries the output in .tool_response; PostToolUseFailure has
    # no .tool_response — the failure text (e.g. "Exit code 127\n...: command
    # not found: foo") is in .error instead (verified empirically).
    resp="$(jq -r '(.tool_response // .error // empty) | if type == "string" then . else tojson end' <<<"$payload")"

    missing=""

    # Shell reported an unknown command. zsh: "command not found: foo",
    # bash: "foo: command not found", fish: "Unknown command: foo". The zsh
    # spelling must be probed first: on a zsh message the bash pattern would
    # match "zsh: command not found" and extract the shell's own name.
    line="$(grep -oE 'command not found: [A-Za-z0-9._+-]+' <<<"$resp" | head -n1 || true)"
    [ -n "$line" ] && missing="''${line##* }"
    if [ -z "$missing" ]; then
      line="$(grep -oE '[A-Za-z0-9._+-]+: command not found' <<<"$resp" | head -n1 || true)"
      [ -n "$line" ] && missing="''${line%%:*}"
    fi
    if [ -z "$missing" ]; then
      line="$(grep -oiE "unknown command:? '?[A-Za-z0-9._+-]+'?" <<<"$resp" | head -n1 || true)"
      if [ -n "$line" ]; then
        missing="''${line##* }"
        missing="''${missing//\'/}"
      fi
    fi

    # A failed PATH probe: the missing name is in the command, not the output.
    if [ -z "$missing" ] && [ "$event" = "PostToolUseFailure" ]; then
      if [[ "$cmd" =~ ^[[:space:]]*(which|type|command[[:space:]]+-v)[[:space:]]+([A-Za-z0-9._+-]+)[[:space:]]*$ ]]; then
        missing="''${BASH_REMATCH[2]}"
      fi
    fi

    [ -z "$missing" ] && exit 0
    # The tool's shell may just have a narrower PATH; if the command resolves
    # here, the hint would be wrong — stay silent.
    command -v "$missing" >/dev/null 2>&1 && exit 0

    jq -n --arg event "$event" --arg m "$missing" '{
      hookSpecificOutput: {
        hookEventName: $event,
        additionalContext: ("`\($m)` is not installed, but this machine runs Nix — do not substitute a different tool. Run it ephemerally: `nix shell nixpkgs#\($m) -c \($m) <args>` (or `nix run nixpkgs#\($m) -- <args>`). If that attribute does not exist, find the right one with `nix search nixpkgs \($m)`.")
      }
    }'
  '';
}

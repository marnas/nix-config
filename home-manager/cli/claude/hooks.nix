{ ... }:
{
  # Shell scripts dropped into ~/.claude/hooks/<name>.
  # Wire them to events (PreToolUse, PostToolUse, Stop, SessionStart, ...)
  # via programs.claude-code.settings.hooks in settings.nix.
  programs.claude-code.hooks = { };
}

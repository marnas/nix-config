{
  writeShellApplication,
  writeText,
  ccstatusline,
  gnused,
}:
let
  # Usage-only ccstatusline config: just the account-level 5-hour block metrics
  # (session %, block reset countdown). colorLevel 0 keeps escapes minimal — we
  # strip the rest below so tmux can apply its own #[fg=...].
  config = writeText "ccstatusline-usage.json" (builtins.toJSON {
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
  });
in
# session-usage + reset-timer are derived from the ~/.claude transcripts (the
# 5-hour billing block, identical across every Claude pane) rather than the
# per-session stdin JSON, so a stub payload renders them fine. Emitted as plain
# text for tmux's status-right `#(...)`.
writeShellApplication {
  name = "claude-usage-tmux";
  runtimeInputs = [
    ccstatusline
    gnused
  ];
  text = ''
    stub='{"model":{"display_name":"x"},"workspace":{"current_dir":"."},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":0}}}'
    out=$(printf '%s' "$stub" | ccstatusline --config ${config} 2>/dev/null) || exit 0
    # Strip ANSI SGR escapes and turn ccstatusline's NBSP padding (UTF-8 C2 A0)
    # into ordinary spaces; tmux renders neither well in the status line.
    printf '%s' "$out" | sed -E $'s/\x1b\\[[0-9;]*m//g; s/\xc2\xa0/ /g'
  '';
}

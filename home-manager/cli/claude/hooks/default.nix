{ pkgs, lib, ... }:
let
  # Plugin lives in pkgs/tmux-agent-indicator and is loaded by tmux.nix.
  # Here we only wire its agent-state.sh into Claude's hook events.
  agentState = "${pkgs.tmux-agent-indicator}/share/tmux-plugins/agent-indicator/scripts/agent-state.sh";

  claudeNotify = import ./notify.nix { inherit pkgs lib; };
  pruneSession = import ./prune-session.nix { inherit pkgs lib; };
  cloudGuard = import ./cloud-guard.nix { inherit pkgs; };
in
{
  programs.claude-code.settings.hooks = {
    # Railguard for online writes: az/terraform/tofu commands that mutate
    # cloud state force the interactive permission prompt in every mode
    # (incl. auto); read-only invocations flow untouched. The `if` filters
    # keep the hook from spawning on unrelated commands. One entry per CLI:
    # `if` takes a single permission rule — pipe-alternation silently matches
    # nothing (verified empirically; the hook never fired with it).
    PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            "if" = "Bash(az *)";
            command = "${cloudGuard}/bin/claude-cloud-guard";
          }
          {
            type = "command";
            "if" = "Bash(terraform *)";
            command = "${cloudGuard}/bin/claude-cloud-guard";
          }
          {
            type = "command";
            "if" = "Bash(tofu *)";
            command = "${cloudGuard}/bin/claude-cloud-guard";
          }
        ];
      }
    ];

    # Sweep leftover promptless transcripts (SessionEnd's async prune can be cut
    # off by a quick /exit); runs synchronously at launch, never touches the
    # session that's starting.
    SessionStart = [
      {
        hooks = [
          {
            type = "command";
            command = "${pruneSession}/bin/claude-prune-session";
          }
        ];
      }
    ];

    # UserPromptSubmit fires off → running (template pattern from the plugin's
    # claude-hooks.json: clears any prior state before marking running).
    UserPromptSubmit = [
      {
        hooks = [
          {
            type = "command";
            command = "${agentState} --agent claude --state off";
          }
          {
            type = "command";
            command = "${agentState} --agent claude --state running";
          }
        ];
      }
    ];

    Stop = [
      {
        hooks = [
          {
            type = "command";
            command = "${agentState} --agent claude --state done";
          }
          {
            type = "command";
            command = "${claudeNotify}/bin/claude-notify normal 'Task complete'";
          }
        ];
      }
    ];

    # Tmux indicator only — no desktop notification. Claude fires Notification
    # on permission prompts AND after 60s of input idle; the latter is noisy
    # and indistinguishable here, so we surface state in tmux instead.
    Notification = [
      {
        hooks = [
          {
            type = "command";
            command = "${agentState} --agent claude --state needs-input";
          }
        ];
      }
    ];

    SessionEnd = [
      {
        hooks = [
          {
            type = "command";
            command = "${agentState} --agent claude --state off";
          }
          # Drop transcripts that never got a real prompt from the resume picker.
          {
            type = "command";
            command = "${pruneSession}/bin/claude-prune-session";
          }
        ];
      }
    ];
  };
}

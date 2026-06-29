{ pkgs, lib, ... }:
# SSH client config, declaratively managed (it used to be a stray hand-written
# ~/.ssh/config containing only the 1Password agent line).
#
# Human ssh authenticates through the 1Password agent (op-ssh, biometric prompt),
# exactly as before. Claude sessions instead route EVERY host through the
# Infisical-keyed session agent (the same dedicated key git already uses via
# git-ssh) — so `ssh`/`rsync`/`scp` to any host never raise a 1Password prompt,
# matching how git push/fetch already works. No per-host entries: the switch is
# the `$CLAUDECODE` marker Claude Code exports, not the destination.
#
# Mechanism: a `Match exec` block (evaluated before `Host *`, first-match-wins)
# that succeeds only when (a) we're inside Claude AND (b) `git-agent-seed`
# successfully loads the Infisical key into its session agent. On success it
# points IdentityAgent at that agent's socket; on any failure (not Claude, or
# Infisical unreachable) the match fails and ssh falls through to the 1Password
# `Host *` default. Linux-only because Claude's workstation is the NixOS box and
# the seeded socket path keys off $XDG_RUNTIME_DIR (unset on macOS, which is
# itself the build host and never the ssh client here).
let
  # Quote-protected so an empty $CLAUDECODE short-circuits BEFORE running the
  # seed (so human ssh pays no latency and never touches Infisical).
  claudeAgentMatch = ''exec "test -n \"$CLAUDECODE\" && ${pkgs.git-agent}/bin/git-agent-seed >/dev/null 2>&1"'';

  # The 1Password SSH-agent socket lives at a different path per OS: a fixed
  # location on Linux, but inside the sandboxed group container on macOS.
  onePasswordAgentSock =
    if pkgs.stdenv.isDarwin then
      # Double-quoted because the path contains a space ("Group Containers");
      # unquoted, ssh's config parser treats it as multiple arguments and aborts.
      "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
    else
      "~/.1password/agent.sock";
in
{
  programs.ssh = {
    enable = true;
    # Replace the deprecated implicit defaults with an explicit `*` block below.
    enableDefaultConfig = false;

    settings = {
      "*" = {
        IdentityAgent = onePasswordAgentSock;
        # Former enableDefaultConfig values, kept verbatim.
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # `header` is set explicitly (not derived from the attr name) because it
      # carries Nix string context — the git-agent store path.
      claude-infisical = lib.hm.dag.entryBefore [ "*" ] {
        header = "Match ${claudeAgentMatch}";
        IdentityAgent = "\${XDG_RUNTIME_DIR}/git-agent/agent.sock";
      };
    };
  };
}

{
  writeShellApplication,
  symlinkJoin,
  openssh,
  jq,
}:
# Claude/agent git access via a session ssh-agent keyed from Infisical — see
# ./git-agent-seed.sh for the rationale. Both wrappers are wired in only for Claude (via
# GIT_CONFIG_* overrides in home-manager/cli/claude/settings.nix); human git is untouched.
# infisical + infisical-token are inherited from PATH (like `op` in the other helpers), so
# they are deliberately not runtimeInputs.
let
  seed = writeShellApplication {
    name = "git-agent-seed";
    runtimeInputs = [
      openssh
      jq
    ];
    text = builtins.readFile ./git-agent-seed.sh;
  };

  # git's gpg.ssh.program: sign through the seeded agent (no 1Password prompt).
  sign = writeShellApplication {
    name = "git-sign-agent";
    runtimeInputs = [
      openssh
      seed
    ];
    text = ''
      sock="$(git-agent-seed)" || exit 1
      export SSH_AUTH_SOCK="$sock"
      exec ssh-keygen "$@"
    '';
  };

  # git's core.sshCommand. core.sshCommand is global for Claude, but only git.marnas.sh
  # should authenticate via the Infisical agent key — every other host (notably github.com,
  # where the agent key is NOT an auth key) must keep the ambient ssh config/agent. So we
  # route to the seeded agent only when git.marnas.sh is among the args, else exec plain ssh
  # untouched. accept-new pins git.marnas.sh's host key on first contact (TOFU).
  push = writeShellApplication {
    name = "git-ssh";
    runtimeInputs = [
      openssh
      seed
    ];
    text = ''
      for arg in "$@"; do
        case "$arg" in
          *git.marnas.sh*)
            sock="$(git-agent-seed)" || exit 1
            export SSH_AUTH_SOCK="$sock"
            exec ssh -o IdentityAgent="$sock" -o StrictHostKeyChecking=accept-new "$@"
            ;;
        esac
      done
      exec ssh "$@"
    '';
  };
in
symlinkJoin {
  name = "git-agent";
  paths = [
    seed
    sign
    push
  ];
}

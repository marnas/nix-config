{ pkgs, lib, ... }:
{
  programs.claude-code.settings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    includeCoAuthoredBy = false;
    cleanupPeriodDays = 30;
    autoUpdates = false;
    # Suppress the 0–4 session-quality survey that pops up intermittently.
    feedbackSurveyRate = 0;
    model = "opus";

    statusLine = {
      type = "command";
      command = lib.getExe pkgs.ccstatusline;
      padding = 0;
    };

    # Give Claude its own git identity via a session ssh-agent keyed from Infisical, instead
    # of 1Password's op-ssh-sign — so neither signing nor pushing raises a biometric prompt.
    # Scoped to Claude only via these GIT_CONFIG_* overrides; human git (op-ssh-sign + the
    # signing key in git.nix) is untouched. The DEDICATED agent key (private half in Infisical
    # as GIT_SSH_KEY, public half below) keeps agent-authored commits attributable; add
    # this pubkey to git.marnas.sh (push + SSH-signature verification) and GitHub (signing).
    #   KEY_0  signer            → git-sign-agent (commit signing through the agent)
    #   KEY_1  user.signingkey   → the agent key's public half
    #   KEY_2  core.sshCommand   → git-ssh (push/fetch auth through the same agent)
    env = {
      # Agent teams (experimental): lead session spawns independent teammate
      # sessions; teammateMode "auto" puts each in its own tmux pane when the
      # lead already runs inside tmux, in-process otherwise.
      CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";

      GIT_CONFIG_COUNT = "3";
      GIT_CONFIG_KEY_0 = "gpg.ssh.program";
      GIT_CONFIG_VALUE_0 = "${pkgs.git-agent}/bin/git-sign-agent";
      GIT_CONFIG_KEY_1 = "user.signingkey";
      GIT_CONFIG_VALUE_1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxIKSHOW5ERkTSIlbD9SfJcAmgY75ETYnioTJGpBga+";
      GIT_CONFIG_KEY_2 = "core.sshCommand";
      GIT_CONFIG_VALUE_2 = "${pkgs.git-agent}/bin/git-ssh";
    };

    # All Claude permissions live HERE, declaratively: no per-project
    # .claude/settings.json files, and no host- or folder-specific rules in
    # this list — keep every rule generic across machines and repos.
    permissions = {
      allow = [
        "Read(**)"
        "Glob"
        "Grep"

        "WebSearch"
        "WebFetch"

        # Filesystem inspection
        "Bash(ls:*)"
        # No `find` — `-exec`/`-delete` make it arbitrary execution; fd covers
        # every read-only use.
        "Bash(fd:*)"
        "Bash(tree:*)"
        "Bash(pwd)"
        "Bash(cat:*)"
        "Bash(head:*)"
        "Bash(tail:*)"
        "Bash(bat:*)"
        "Bash(wc:*)"
        "Bash(file:*)"
        "Bash(stat:*)"
        "Bash(du:*)"
        "Bash(df:*)"
        "Bash(readlink:*)"
        "Bash(realpath:*)"
        "Bash(dirname:*)"
        "Bash(basename:*)"

        # Text processing (read-only)
        "Bash(rg:*)"
        "Bash(grep:*)"
        "Bash(jq:*)"
        "Bash(yq:*)"
        "Bash(diff:*)"
        "Bash(sort:*)"
        "Bash(uniq:*)"
        "Bash(cut:*)"
        "Bash(tr:*)"
        "Bash(column:*)"

        # System inspection
        "Bash(which:*)"
        "Bash(whoami)"
        "Bash(hostname)"
        "Bash(uname:*)"
        "Bash(date:*)"
        "Bash(env)"
        "Bash(echo:*)"
        "Bash(printf:*)"
        "Bash(ps:*)"
        "Bash(ss:*)"
        "Bash(lsblk:*)"
        "Bash(lsusb:*)"
        "Bash(lspci:*)"
        "Bash(systemctl status:*)"
        "Bash(systemctl list-units:*)"
        "Bash(systemctl list-unit-files:*)"
        "Bash(systemctl cat:*)"
        "Bash(systemctl is-active:*)"
        "Bash(systemctl is-enabled:*)"
        "Bash(journalctl:*)"

        # Read-only git
        "Bash(git pull:*)"
        "Bash(git status:*)"
        "Bash(git log:*)"
        "Bash(git diff:*)"
        "Bash(git show:*)"
        "Bash(git branch:*)"
        "Bash(git remote:*)"
        "Bash(git config --get:*)"
        "Bash(git config --list:*)"
        "Bash(git ls-files:*)"
        "Bash(git rev-parse:*)"
        "Bash(git blame:*)"
        "Bash(git fetch:*)"
        "Bash(git stash list:*)"
        "Bash(git stash show:*)"

        # Read-only GitHub CLI
        "Bash(gh pr view:*)"
        "Bash(gh pr list:*)"
        "Bash(gh pr diff:*)"
        "Bash(gh pr checks:*)"
        "Bash(gh issue view:*)"
        "Bash(gh issue list:*)"
        "Bash(gh run list:*)"
        "Bash(gh run view:*)"
        "Bash(gh release list:*)"
        "Bash(gh release view:*)"
        "Bash(gh repo view:*)"
        "Bash(gh api:*)"
        "Bash(gh search:*)"

        # Read-only dev tooling
        "Bash(npm ls:*)"
        "Bash(npm view:*)"
        "Bash(npm outdated:*)"
        "Bash(pnpm list:*)"
        "Bash(pnpm why:*)"
        "Bash(yarn list:*)"
        "Bash(pip show:*)"
        "Bash(pip list:*)"
        "Bash(uv pip list:*)"
        "Bash(cargo tree:*)"
        "Bash(cargo metadata:*)"
        "Bash(go list:*)"
        "Bash(go version)"
        "Bash(node --version)"
        "Bash(python --version)"

        # Read-only containers
        "Bash(docker ps:*)"
        "Bash(docker images:*)"
        "Bash(docker logs:*)"
        "Bash(docker inspect:*)"
        "Bash(podman ps:*)"
        "Bash(podman images:*)"
        "Bash(podman logs:*)"

        # Read-only nix
        "Bash(nix eval:*)"
        "Bash(nix flake metadata:*)"
        "Bash(nix flake show:*)"
        "Bash(nix flake check:*)"
        "Bash(nix derivation show:*)"
        "Bash(nix path-info:*)"
        "Bash(nix store ls:*)"
        "Bash(nix store info:*)"
        "Bash(nix-store --query:*)"
        "Bash(nix build --no-link:*)"
        "Bash(nix repl:*)"
        # Writes, but only canonical formatting — required on every touched
        # .nix file anyway, so prompting for it is pure friction.
        "Bash(nix run nixpkgs#nixfmt:*)"

        # Anytype management (the `any` skill CLI — capture/list/update/close
        # objects in the self-hosted space on my behalf, incl. recreate + rm).
        "Bash(any:*)"

        # Misc — no xargs (runs arbitrary commands, voiding the read-only list)
        # and no chmod (state-changing, rare under Nix anyway).
        "Bash(ffprobe:*)"
      ];

      # Keep this list minimal: an explicit `ask` overrides the permission
      # mode, forcing a prompt even in auto/acceptEdits — so everything not
      # listed here flows under the active mode. Force pushes are the one
      # deterministic railguard (history rewrite on a remote); other
      # remote-mutating commands are handled by the auto-mode classifier and
      # the autoMode.soft_deny rule below. A `*` spans spaces, so these four
      # patterns cover --force / --force-with-lease / -f in any position.
      ask = [
        "Bash(git push --force*)"
        "Bash(git push * --force*)"
        "Bash(git push -f*)"
        "Bash(git push * -f*)"
      ];

      deny = [
        "Read(**/.env)"
        # Deny real env files, but allow the committed example/template variants.
        "Read(**/.env.!(example|sample|template))"
        "Read(**/*credentials*)"
      ];

      # Trusted paths outside the working directory.
      # Without these, read-only commands that touch (e.g.) /nix/store still
      # trigger per-directory prompts even when the Bash rule is allowed.
      additionalDirectories = [
        "/nix/store"
        "~/.dotfiles"
        "~/.claude"
      ];
    };
  };
}

{ pkgs, lib, ... }:
{
  programs.claude-code.settings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    includeCoAuthoredBy = false;
    cleanupPeriodDays = 30;
    autoUpdates = false;
    model = "opus";

    statusLine = {
      type = "command";
      command = lib.getExe pkgs.ccstatusline;
      padding = 0;
    };

    env = { };

    permissions = {
      allow = [
        "Read(**)"
        "Glob"
        "Grep"

        "WebSearch"
        "WebFetch"

        # Filesystem inspection
        "Bash(ls:*)"
        "Bash(find:*)"
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

        # Misc
        "Bash(ffprobe:*)"
        "Bash(xargs:*)"
        "Bash(chmod:*)"
      ];

      ask = [
        "Edit(**)"
        "Write(**)"
        "Bash(:*:*)"
        "NotebookEdit(**)"
      ];

      deny = [
        "Read(**/.env)"
        "Read(**/.env.*)"
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

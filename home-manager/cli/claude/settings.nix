{ ... }:
{
  programs.claude-code.settings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    includeCoAuthoredBy = false;
    cleanupPeriodDays = 30;
    autoUpdates = false;

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
        "Read(**/*password*)"
        "Read(**/*credentials*)"
      ];
    };
  };
}

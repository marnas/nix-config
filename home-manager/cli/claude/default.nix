{ pkgs, config, ... }: {
  programs.claude-code = {
    enable = true;

    # Point to the hooks directory
    hooksDir = ./hooks;

    # Claude Code settings
    settings = {
      # Permission configuration
      permissions = {
        allow = [
          "Read(**)"
          "Glob"
          "Grep"
          "Bash(ls*)"
          "Bash(find*)"
          "Bash(pwd)"
          "Bash(cat*)"
          "Bash(head*)"
          "Bash(tail*)"
        ];
        ask = [
          "Edit(**)"
          "Write(**)"
          "Bash(**)"
          "NotebookEdit(**)"
        ];
        deny = [
          "Read(**/.env)"
          "Read(**/.env.*)"
          "Read(**/secrets/**)"
          "Read(**/*secret*)"
          "Read(**/*password*)"
          "Read(**/*credentials*)"
        ];
      };

      # Hook configuration
      hooks = {
        PreToolUse = [
          {
            matcher = "Bash";
            hooks = [
              {
                type = "command";
                command = "~/.claude/hooks/check-local-repos.py";
              }
              {
                type = "command";
                command = "~/.claude/hooks/nix-comma-helper.py";
              }
            ];
          }
        ];
      };
    };
  };
}

{ pkgs, config, ... }: {
  programs.claude-code = {
    enable = true;

    # Note: Cannot use both hooksDir and settings.hooks - they are mutually exclusive
    # Using settings.hooks for inline configuration instead of hooksDir

    # Claude Code settings
    settings = {
      hooks = {
        PreToolUse = [{
          matcher = "Bash";
          hooks = [{
            type = "command";
            command = "${./hooks/nix-comma-helper.py}";
          }];
        }];
      };

      # Permission configuration
      permissions = {
        allow = [
          "Read(**)"
          "Glob"
          "Grep"
          "Bash(ls:*)"
          "Bash(find:*)"
          "Bash(pwd)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
        ];
        ask = [ "Edit(**)" "Write(**)" "Bash(:*:*)" "NotebookEdit(**)" ];
        deny = [
          "Read(**/.env)"
          "Read(**/.env.*)"
          "Read(**/secrets/**)"
          "Read(**/*secret*)"
          "Read(**/*password*)"
          "Read(**/*credentials*)"
        ];
      };

    };
  };
}

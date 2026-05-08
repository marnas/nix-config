{ ... }:
{
  programs.claude-code = {
    enable = true;

    # Claude Code settings
    settings = {
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
  };
}

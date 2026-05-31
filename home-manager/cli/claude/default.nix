{ ... }:
{
  imports = [
    ./settings.nix
    ./hooks
    ./mcp.nix
  ];

  programs.claude-code = {
    enable = true;

    context = ./context.md;

    agentsDir = ./agents;
    commandsDir = ./commands;
    skillsDir = ./skills;
  };
}

{ ... }:
{
  imports = [
    ./settings.nix
    ./hooks.nix
    ./mcp.nix
  ];

  programs.claude-code = {
    enable = true;

    context = ./context.md;

    agentsDir = ./agents;
    commandsDir = ./commands;
  };
}

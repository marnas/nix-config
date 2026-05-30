{ ... }:
{
  # Example entry shape:
  #   github = { type = "http"; url = "https://api.githubcopilot.com/mcp/"; };
  #   local  = { type = "stdio"; command = "..."; args = [ ]; env = { }; };
  programs.claude-code.mcpServers = { };
}

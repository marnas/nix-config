{ pkgs, lib, ... }:
let
  # The whole statusline is one jq pass over the JSON Claude Code pipes in —
  # see statusline.jq for the field mapping, Ctx math, and color thresholds.
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      jq -rj -f ${./statusline.jq}
    '';
  };
in
{
  programs.claude-code.settings.statusLine = {
    type = "command";
    command = lib.getExe statusline;
    padding = 0;
  };
}

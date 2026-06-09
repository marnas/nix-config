# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs ? import <nixpkgs> { },
}:
{
  ccstatusline = pkgs.callPackage ./ccstatusline { };
  claude-usage-refresh = pkgs.callPackage ./claude-usage-refresh { };
  claude-usage-tmux = pkgs.callPackage ./claude-usage-tmux { };
  git-agent = pkgs.callPackage ./git-agent { };
  tilish-colemak = pkgs.callPackage ./tilish-colemak { };
  tmux-agent-indicator = pkgs.callPackage ./tmux-agent-indicator { };
}

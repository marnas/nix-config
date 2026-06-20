# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs ? import <nixpkgs> { },
}:
{
  actual-cli = pkgs.callPackage ./actual-cli { };
  ccstatusline = pkgs.callPackage ./ccstatusline { };
  claude-usage-refresh = pkgs.callPackage ./claude-usage-refresh { };
  claude-usage-tmux = pkgs.callPackage ./claude-usage-tmux { };
  forgejo-cli = pkgs.callPackage ./forgejo-cli { };
  git-agent = pkgs.callPackage ./git-agent { };
  tilish-colemak = pkgs.callPackage ./tilish-colemak { };
  tradingview = pkgs.callPackage ./tradingview { };
  tmux-agent-indicator = pkgs.callPackage ./tmux-agent-indicator { };
}

# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{
  pkgs ? import <nixpkgs> { },
}:
{
  actual-cli = pkgs.callPackage ./actual-cli { };
  claude-usage = pkgs.callPackage ./claude-usage { };
  forgejo-cli = pkgs.callPackage ./forgejo-cli { };
  git-agent = pkgs.callPackage ./git-agent { };
  tilish-colemak = pkgs.callPackage ./tilish-colemak { };
  tradingview = pkgs.callPackage ./tradingview { };
  tmux-agent-indicator = pkgs.callPackage ./tmux-agent-indicator { };
}

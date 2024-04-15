# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  tilish-colemak = pkgs.callPackage ./tilish-colemak { };
  wowup = pkgs.callPackage ./wowup { };
  wowup-cf = pkgs.callPackage ./wowup-cf { };
}

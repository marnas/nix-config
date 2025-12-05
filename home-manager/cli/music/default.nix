{ ... }:
let
  musicDirectory = "/mnt/media/music";
in {
  _module.args = { inherit musicDirectory; };

  imports = [
    ./mpd.nix
    ./rmpc.nix
  ];
}

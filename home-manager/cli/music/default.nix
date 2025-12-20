{ vars, ... }:
let
  musicDirectory = if vars.hostname == "macos" then
    "/nfs/media/music"
  else
    "/mnt/media/music";
in {
  _module.args = { inherit musicDirectory; };

  imports = [ ./mpd.nix ./rmpc.nix ];
}

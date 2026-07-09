{ ... }:
{
  homebrew = {
    enable = true;
    global.autoUpdate = true;

    casks = [
      "1password"
      "anytype"
      # "arc"
      #"autodesk-fusion"
      "firefox"
      #"garmin-express"
      #"hammerspoon"
      #"kicad"
      "nextcloud"
      #"orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale-app"
      #"vlc"
    ];
  };
}

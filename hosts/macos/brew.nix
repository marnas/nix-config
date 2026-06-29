{ ... }:
{
  homebrew = {
    enable = true;
    global.autoUpdate = true;

    casks = [
      "1password"
      "1password-cli"
      "anytype"
      "arc"
      #"autodesk-fusion"
      "docker-desktop"
      "firefox"
      #"garmin-express"
      "ghostty"
      #"hammerspoon"
      #"kicad"
      "nextcloud"
      "nordpass"
      #"orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale-app"
    ];
  };
}

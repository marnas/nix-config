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
      "cloudflare-warp"
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
      "windows-app"
    ];
  };
}

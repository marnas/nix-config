{ ... }:
{
  homebrew = {
    enable = true;
    global.autoUpdate = true;

    casks = [
      "1password"
      "1password-cli"
      "alacritty"
      "anytype"
      # "arc"
      #"autodesk-fusion"
      "firefox"
      #"garmin-express"
      "ghostty"
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

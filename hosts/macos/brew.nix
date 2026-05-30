{ ... }:
{
  homebrew = {
    enable = true;
    global.autoUpdate = true;

    casks = [
      "1password"
      "1password-cli"
      "arc"
      #"autodesk-fusion"
      "docker-desktop"
      #"garmin-express"
      "ghostty"
      #"hammerspoon"
      #"kicad"
      "nextcloud"
      "obsidian"
      #"orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale-app"
    ];
  };
}

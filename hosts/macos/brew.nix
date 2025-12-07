{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "arc"
      #"autodesk-fusion"
      "docker-desktop"
      #"garmin-express"
      "gather"
      "hammerspoon"
      "kicad"
			"monal"
      "nextcloud"
      "obsidian"
      "orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale-app"
      "whatsapp"
    ];
  };
}

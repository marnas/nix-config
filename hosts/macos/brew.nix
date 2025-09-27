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
      "kicad"
      "nextcloud"
      "obsidian"
      "orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale-app"
      "transmission-remote-gui"
      "whatsapp"
      "zen"
    ];
  };
}

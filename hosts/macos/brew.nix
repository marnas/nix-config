{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "altserver"
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

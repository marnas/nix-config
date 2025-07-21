{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "arc"
      #"autodesk-fusion"
      #"garmin-express"
      "gather"
      "nextcloud"
      "obsidian"
      "orcaslicer"
      "plex"
      "plexamp"
      #"soulseek"
      "tailscale"
      "transmission-remote-gui"
      "whatsapp"
      "zen-browser"
    ];
  };
}

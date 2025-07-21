{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "1password"
      "arc"
      #"autodesk-fusion"
      "firefox"
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

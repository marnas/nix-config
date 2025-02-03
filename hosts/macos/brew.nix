{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "1password"
      "arc"
      #"autodesk-fusion"
      "docker"
      #"garmin-express"
      "gather"
      #"hackintool"
      # "karabiner-elements"
      "nextcloud"
      "obsidian"
      #"opencore-configurator"
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

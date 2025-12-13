{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = true;
    brews = [ "helm" ];

    casks = [
      "1password"
      "1password-cli"
      "arc"
      #"autodesk-fusion"
      "docker-desktop"
      #"garmin-express"
      "gather"
      "ghostty"
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

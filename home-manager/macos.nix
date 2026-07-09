{
  pkgs,
  lib,
  config,
  ...
}:
{

  imports = [
    ./cli
    ./shared.nix
  ];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # maccy
    _1password-cli # on NixOS the CLI comes with the system-level programs._1password
    azure-cli
    google-cloud-sdk
    colima # Docker daemon on macOS (replaces Docker Desktop)
    docker-client # docker CLI only; the daemon lives in the colima VM
    docker-compose
  ];

  # Auto-start the colima VM at login, mirroring `brew services start colima`
  # (which runs `colima start --foreground`). vz = Apple Virtualization.framework:
  # lighter and faster than qemu on Apple Silicon, with memory ballooning so idle
  # RAM is reclaimed by the host. Run `colima stop` to drop the VM entirely; the
  # clean exit won't be relaunched (KeepAlive only restarts on crash).
  launchd.agents.colima = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
        "--foreground"
        "--vm-type"
        "vz"
      ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/colima.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/colima.log";
      # colima's startup dependency check needs the docker CLI on PATH; launchd
      # gives a minimal PATH, so add it explicitly (plus /usr/bin for ssh, which
      # lima shells out to).
      EnvironmentVariables.PATH = "${
        lib.makeBinPath [
          pkgs.docker-client
          pkgs.colima
        ]
      }:/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };

  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 7.0;
      hidpi = "on";
      # Cyan→green diagonal, mirrors Hyprland's `col.active_border`
      # (rgba(33ccffee) rgba(00ff99ee) 45deg). Flip top_left/bottom_right
      # if the diagonal lands the wrong way. Embedded quotes are required:
      # home-manager renders settings into a bash array, and the parens in
      # `gradient(...)` would otherwise be parsed as a subshell.
      active_color = ''"gradient(top_left=0xee33ccff,bottom_right=0xee00ff99)"'';
      # Transparent inactive border hides the grey→blue flash on aerospace
      # workspace switches (a known unresolved interaction, see
      # FelixKratz/JankyBorders#79, #182). With no inactive border to
      # mis-draw, the fast SkyLight path is safe again.
      inactive_color = "0x00000000";
      ax_focus = "off";
    };
  };

  targets.darwin.defaults."com.apple.desktopservices" = {
    DSDontWriteUSBStores = true;
    DSDontWriteNetworkStores = true;
  };

  home.activation.spotlight = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/defaults write com.apple.Spotlight EnabledPreferenceRules -array \
      'Custom.relatedContents' \
      'System.files' \
      'System.folders' \
      'System.iphoneApps' \
      'System.menuItems'
    /usr/bin/defaults write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2
    /usr/bin/killall Spotlight 2>/dev/null || true
  '';

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "26.05";
}

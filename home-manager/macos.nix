{ pkgs, lib, ... }:
{

  imports = [
    ./cli
    ./shared.nix
  ];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # colima
    # maccy
    vlc-bin-universal
  ];

  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 8.0;
      hidpi = "on";
      active_color = "0xff82b8c8";
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

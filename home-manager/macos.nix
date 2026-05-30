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

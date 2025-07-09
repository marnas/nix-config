{ pkgs, ... }: {

  imports = [ ./cli ./shared.nix ];

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # colima
    raycast
    vlc-bin-universal
  ];

  targets.darwin.defaults."com.apple.desktopservices" = {
    DSDontWriteUSBStores = true;
    DSDontWriteNetworkStores = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.11";
}

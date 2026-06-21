{ outputs, ... }:
{
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      # auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
        "@admin"
      ];
      trusted-substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    optimise.automatic = true;
    gc = {
      automatic = true;
      # dates = "weekly";
      # Generation count is capped via boot.loader.systemd-boot.configurationLimit (5);
      # nix-collect-garbage only supports age-based pruning, so this just reclaims
      # store space by age.
      options = "--delete-older-than 30d";
    };
  };
}

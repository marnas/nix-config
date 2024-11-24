{ outputs, ... }: {
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages
    ];

    config = { allowUnfree = true; };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      # auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      trusted-substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    optimise.automatic = true;
    gc = {
      automatic = true;
      #dates = "weekly";
      # Keep the last 5 generations
      options = "--delete-generations +5";
    };
  };
}

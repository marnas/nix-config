{
  description = "Marnas Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, hyprland, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages.${system};

      # configure pkgs
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true;
                   allowUnfreePredicate = (_: true); };
        #overlays = [ rust-overlay.overlays.default ];
      };

      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config = { allowUnfree = true;
                   allowUnfreePredicate = (_: true); };
        #overlays = [ rust-overlay.overlays.default ];
      };
    in {

    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
	modules = [ ./configuration.nix ];
      };
    };
    homeConfigurations = {
      marnas = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	modules = [
	  ./home.nix
          hyprland.homeManagerModules.default
          {wayland.windowManager.hyprland.enable = true;}
	];
      };
    };
  };

}

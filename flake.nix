{
  description = "Marnas Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, split-monitor-workspaces, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      #pkgs = nixpkgs.legacyPackages.${system};

      # configure pkgs
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

    in
    {

      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
        };
      };
      homeConfigurations = {
        # useGlobalPkgs = true;
        # useUserPackages = true;
        marnas = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            hyprland.homeManagerModules.default
            {
              wayland.windowManager.hyprland = {
                enable = true;
                plugins = [
                  split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
                ];
              };
            }
          ];
        };
      };
    };

}

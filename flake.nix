{
  inputs = {

    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

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

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , split-monitor-workspaces
    , ...
    }@ inputs:
    let
      inherit (self) outputs;

      lib = nixpkgs.lib;
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

    in
    {

      overlays = import ./overlays { inherit inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > main nixos configuration file <
            ./nixos/configuration.nix
          ];
        };
      };


      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "marnas@nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          # extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/home.nix

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

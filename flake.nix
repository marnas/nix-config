{
  inputs = {

    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      # url = "github:hyprwm/hyprland";
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , hyprland
    , nix-darwin
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
            ./hosts/nixos/configuration.nix
          ];
        };

        noxis = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # > main nixos configuration file <
            ./hosts/noxis/configuration.nix
          ];
        };
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#evombp05evolvere-techcom
      darwinConfigurations = {
        evombp05evolvere-techcom = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/evo/configuration.nix
          ];
        };

        # $ darwin-rebuild build --flake .#macos
        macos = nix-darwin.lib.darwinSystem {
          # system = "x86_64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/macos/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        useGlobalPkgs = true;
        useUserPackages = true;

        "marnas@nixos" = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/nixos.nix
          ];
        };
        "marnas@noxis" = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/noxis.nix
          ];
        };

        "marnas@macos" = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs = nixpkgs.legacyPackages.x86_64-darwin; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/macos.nix
          ];
        };
      };

    };
}


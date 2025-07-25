{
  nixConfig = {
    extra-substituters =
      [ "https://nix-community.cachix.org" "https://hyprland.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
      # url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    marnas-nvim = { url = "github:marnas/nvim-flake"; };

    mac-app-util = { url = "github:hraban/mac-app-util"; };

    nix-minecraft = { url = "github:Infinidoge/nix-minecraft"; };
  };

  outputs =
    { self, nixpkgs, home-manager, nix-darwin, mac-app-util, ... }@inputs:
    let inherit (self) outputs;
    in {

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

      darwinConfigurations = {
        # darwin-rebuild switch --flake .#conduktOS
        conduktOS = nix-darwin.lib.darwinSystem {
          # system = "x86_64-darwin";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/conduktOS/configuration.nix
            mac-app-util.darwinModules.default
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
          pkgs =
            nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
            vars = { hostname = "nixos"; };
          };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/nixos.nix
          ];
        };
        "marnas@noxis" = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs =
            nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
            vars = { hostname = "noxis"; };
          };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/noxis.nix
          ];
        };
        "marnas@conduktOS" = home-manager.lib.homeManagerConfiguration {
          #inherit pkgs;
          pkgs =
            nixpkgs.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = {
            inherit inputs outputs;
            vars = { hostname = "macos"; };
          };
          modules = [
            # > main home-manager configuration file <
            ./home-manager/conduktOS.nix
            mac-app-util.homeManagerModules.default
          ];
        };
      };

    };
}


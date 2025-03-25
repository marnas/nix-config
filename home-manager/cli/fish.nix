{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
  hasBat = hasPackage "bat";
  hasEza = hasPackage "eza";
  hasKubectl = hasPackage "kubectl";
  hasTerraform = hasPackage "terraform";
in {
  programs.fish = {
    enable = true;
    shellAbbrs = {

      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

      cat = mkIf hasBat "bat";
      ls = mkIf hasEza "eza";
      k = mkIf hasKubectl "kubectl";
      tf = mkIf hasTerraform "terraform";

    };
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
    functions = {
      # Disable greeting
      fish_greeting = "";
    };
    interactiveShellInit = ''
      bind \ey edit_command_buffer
    '';
  };
}


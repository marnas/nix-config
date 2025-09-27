{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
  hasBat = hasPackage "bat";
  hasEza = hasPackage "eza";
  hasGit = hasPackage "git";
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

      # Git abbreviations
      ga = mkIf hasGit "git add";
      gc = mkIf hasGit "git commit -m";
      gd = mkIf hasGit "git diff";

    };
    shellAliases = {
      # Clear screen and scrollback
      cls = "printf '\\033[2J\\033[3J\\033[1;1H'";

      cat = mkIf hasBat "bat";
      ls = mkIf hasEza "eza";
      k = mkIf hasKubectl "kubectl";
      tf = mkIf hasTerraform "terraform";

      # Git aliases
      g = mkIf hasGit "git";
      gst = mkIf hasGit "git status";
      gdf = mkIf hasGit "git diff :!flake.lock";

    };
    plugins = [{
      name = "z";
      src = pkgs.fishPlugins.z.src;
    }];
    functions = {
      # Disable greeting
      fish_greeting = "";
    };
    interactiveShellInit = ''
      bind \ey edit_command_buffer
      set fish_cursor_insert block
      fish_vi_key_bindings
    '';
  };
}


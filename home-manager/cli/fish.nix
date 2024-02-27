{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
  hasExa = hasPackage "eza";
  hasBat = hasPackage "bat";
in
{
  programs.fish = {
    enable = true;
    shellAbbrs = rec {

      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

    };
    shellAliases = {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";

      cat = mkIf hasBat "bat";

      ls = mkIf hasExa "eza";
      l = mkIf hasExa "eza -al";

    };
    # functions = {
    #   # Disable greeting
    #   fish_greeting = "";
    #   # Merge history upon doing up-or-search
    #   # This lets multiple fish instances share history
    #   up-or-search = /* fish */ ''
    #     if commandline --search-mode
    #       commandline -f history-search-backward
    #       return
    #     end
    #     if commandline --paging-mode
    #       commandline -f up-line
    #       return
    #     end
    #     set -l lineno (commandline -L)
    #     switch $lineno
    #       case 1
    #         commandline -f history-search-backward
    #         history merge
    #       case '*'
    #         commandline -f up-line
    #     end
    #   '';
    # };
    interactiveShellInit = /* fish */ ''
      # Open command buffer in vim when alt+e is pressed
      bind \ee edit_command_buffer

      # Use terminal colors
      set -U fish_color_autosuggestion      brblack
      set -U fish_color_cancel              -r
      set -U fish_color_command             brgreen
      set -U fish_color_comment             brmagenta
      set -U fish_color_cwd                 green
      set -U fish_color_cwd_root            red
      set -U fish_color_end                 brmagenta
      set -U fish_color_error               brred
      set -U fish_color_escape              brcyan
      set -U fish_color_history_current     --bold
      set -U fish_color_host                normal
      set -U fish_color_match               --background=brblue
      set -U fish_color_normal              normal
      set -U fish_color_operator            cyan
      set -U fish_color_param               brblue
      set -U fish_color_quote               yellow
      set -U fish_color_redirection         bryellow
      set -U fish_color_search_match        'bryellow' '--background=brblack'
      set -U fish_color_selection           'white' '--bold' '--background=brblack'
      set -U fish_color_status              red
      set -U fish_color_user                brgreen
      set -U fish_color_valid_path          --underline
      set -U fish_pager_color_completion    normal
      set -U fish_pager_color_description   yellow
      set -U fish_pager_color_prefix        'white' '--bold' '--underline'
      set -U fish_pager_color_progress      'brwhite' '--background=cyan'

      # AWS CLI completions (https://github.com/aws/aws-cli/issues/1079)
      complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
    '';
  };
}


{
  pkgs,
  lib,
  vars,
  ...
}:
{

  programs.alacritty = {
    enable = true;
    # On macOS the .app comes from the brew cask (no mac-app-util trampolines
    # for nix-installed apps anymore); home-manager only manages the config.
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    settings = {
      terminal.shell = "${pkgs.fish}/bin/fish";

      font = lib.mkIf (vars.hostname == "macos") {
        normal = {
          family = "FiraCode Nerd Font";
          # style = "Regular";
        };
        size = 14;
      };

      scrolling = {
        history = 10000;
      };

      window = {
        option_as_alt = "OnlyLeft";
        decorations = "Buttonless";
      };

      mouse.bindings = [
        {
          mouse = "Middle";
          action = "PasteSelection";
        }
      ];

      keyboard.bindings = [
        {
          chars = "\\u2310";
          key = "Tab";
          mods = "Control";
        }
        {
          chars = "\\u00AC";
          key = "Tab";
          mods = "Control|Shift";
        }
      ];

    };
  };

}

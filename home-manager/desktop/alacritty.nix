{ pkgs, lib, vars, ... }: {

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = "${pkgs.fish}/bin/fish";

      font = lib.mkIf (vars.hostname == "macos") {
        normal = {
          family = "FiraCode Nerd Font";
          # style = "Regular";
        };
        size = 12;
      };

      scrolling = { history = 10000; };

      window = {
        option_as_alt = "OnlyLeft";
        decorations = "Buttonless";
      };

      mouse.bindings = [{
        mouse = "Middle";
        action = "PasteSelection";
      }];

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

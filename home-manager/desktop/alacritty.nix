{ pkgs, lib, vars, ... }: {

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = "${pkgs.fish}/bin/fish";

      font = lib.mkIf (vars.hostname == "macos") {
        normal = {
          family = "MesloLGL Nerd Font";
          #style = "Regular";
        };
        size = 13;
      };

      scrolling = { history = 10000; };

      window = { option_as_alt = "Both"; };

      mouse.bindings = [{
        mouse = "Middle";
        action = "PasteSelection";
      }];

      keyboard.bindings = [
        {
          chars = "\\u001B[9;5u";
          key = "Tab";
          mods = "Control";
        }
        {
          chars = "\\u001B[9;6u";
          key = "Tab";
          mods = "Control|Shift";
        }
      ];

    };
  };

}

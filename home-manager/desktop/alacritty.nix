{ ... }: {

  programs.alacritty = {
    enable = true;
    settings = {

      scrolling = {
        history = 10000;
      };

      # font = {
      # size = 12;
      # };

      window = {
        option_as_alt = "Both";
      };

      mouse.bindings = [
        { mouse = "Middle"; action = "PasteSelection"; }
      ];

      keyboard.bindings = [
        { chars = "\\u001B[9;5u"; key = "Tab"; mods = "Control"; }
        { chars = "\\u001B[9;6u"; key = "Tab"; mods = "Control|Shift"; }
      ];

    };
  };

}

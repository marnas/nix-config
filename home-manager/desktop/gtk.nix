{ pkgs, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 24;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 24;
    };

    # font.name = "TeX Gyre Adventor 10";
    theme = {
      name = "Andromeda";
      package = pkgs.andromeda-gtk-theme;
    };
    # iconTheme = {
    #   name = "Kora";
    #   package = pkgs.kora-icon-theme;
    # };
  };

  qt.enable = true;
}

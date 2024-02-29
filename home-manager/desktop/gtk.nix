{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    name = "breeze_cursors";
    package = pkgs.breeze-gtk;
    size = 30;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.breeze-gtk;
      name = "breeze_cursors";
      size = 30;
    };
    # font.name = "TeX Gyre Adventor 10";
    theme = {
      name = "Juno-mirage";
      package = pkgs.juno-theme;
    };
    iconTheme = {
      name = "Nordic-bluish";
      package = pkgs.nordic;
    };
  };

  qt.enable = true;
}

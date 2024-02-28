{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    name = "Nordic-cursors";
    package = pkgs.nordic;
    size = 30;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.nordic;
      name = "Nordic-cursors";
      size = 30;
    };
    # font.name = "TeX Gyre Adventor 10";
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
    iconTheme = {
      name = "Nordic-darker";
      package = pkgs.nordic;
    };
  };

  qt.enable = true;
}

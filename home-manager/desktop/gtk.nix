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

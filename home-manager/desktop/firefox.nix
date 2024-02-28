{ pkgs, ... }:

{
  programs.browserpass.enable = true;
  programs.firefox = {
    enable = true;
    # preferences = {
    # "widget.use-xdg-desktop-portal.file-picker" = 1;
    # "widget.use-xdg-desktop-portal.mime-handler" = 1;
    # };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

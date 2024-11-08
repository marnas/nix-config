{ ... }:

{
  programs.browserpass.enable = true;
  programs.firefox = {
    enable = true;
    # preferences = {
    # "widget.use-xdg-desktop-portal.file-picker" = 1;
    # "widget.use-xdg-desktop-portal.mime-handler" = 1;
    # };
  };
}

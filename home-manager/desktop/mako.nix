{ ... }: {

  services.mako = {
    enable = false;
    sort = "-time";
    layer = "overlay";
    backgroundColor = "#2e3440";
    width = 300;
    height = 110;
    borderSize = 1;
    borderColor = "#88c0d0";
    borderRadius = 10;
    icons = true;
    maxIconSize = 64;
    defaultTimeout = 10000;
    ignoreTimeout = true;
    font = "monospace 12";

    extraConfig = ''
      [urgency=low]
      border-color=#cccccc

      [urgency=normal]
      border-color=#d08770

      [urgency=high]
      border-color=#bf616a
      default-timeout=0

      [category=mpd]
      default-timeout=2000
      group-by=category
    '';
  };
}

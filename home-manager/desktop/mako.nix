{ ... }: {

  services.mako = {
    enable = true;
    actions = true;
    icons = true;
    # maxIconSize = 64;
    sort = "-time";
    # layer = "overlay";
    padding = "20";
    margin = "10,10,0";
    width = 400;
    # height = 110;
    borderSize = 1;
    borderColor = "#2d2a2e";
    borderRadius = 10;
    backgroundColor = "#eff1f5";
    progressColor = "over #ccd0da";
    defaultTimeout = 10000;
    ignoreTimeout = true;
    font = "Helvetica 11";
    textColor = "#4c4f69";

    extraConfig = ''
      [urgency=high]
      border-color=#f01326
      default-timeout=0
    '';
  };
}

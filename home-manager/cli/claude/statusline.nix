{ pkgs, ... }:
let
  # ccstatusline reads ~/.config/ccstatusline/settings.json. Managing it here
  # makes the statusline config version-controlled and synced across hosts.
  # Trade-off: the file becomes a read-only store symlink, so the `ccstatusline`
  # TUI can no longer save changes — edit this attrset instead.
  settings = {
    version = 3;
    lines = [
      [
        {
          id = "1";
          type = "model";
          color = "cyan";
        }
        {
          id = "2";
          type = "separator";
        }
        {
          id = "3";
          type = "context-length";
          color = "brightBlack";
        }
        {
          id = "4";
          type = "separator";
        }
        {
          id = "5";
          type = "git-branch";
          color = "magenta";
        }
        {
          id = "6";
          type = "separator";
        }
        {
          id = "7";
          type = "git-changes";
          color = "yellow";
        }
      ]
      [ ]
      [ ]
    ];
    flexMode = "full-minus-40";
    compactThreshold = 60;
    colorLevel = 2;
    inheritSeparatorColors = false;
    globalBold = false;
    gitCacheTtlSeconds = 5;
    minimalistMode = false;
    powerline = {
      enabled = false;
      separators = [ "" ];
      separatorInvertBackground = [ false ];
      startCaps = [ ];
      endCaps = [ ];
      autoAlign = false;
      continueThemeAcrossLines = false;
    };
  };
in
{
  home.packages = [ pkgs.ccstatusline ];

  # Customize via the `ccstatusline` TUI first (writes to ~/.config), then copy
  # the result into the `settings` attrset above and uncomment to make it
  # declarative + synced. While commented, the TUI owns the file.
  # xdg.configFile."ccstatusline/settings.json".source =
  #   (pkgs.formats.json { }).generate "ccstatusline-settings.json" settings;
}

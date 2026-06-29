{ ... }:
let
  user = "marco.santonastaso";
  screenshotsLocation = "~/Pictures/screenshots";
in
{
  system = {
    primaryUser = "${user}";
    defaults = {
      loginwindow.LoginwindowText = "";
      screencapture.location = "${screenshotsLocation}";
      screensaver.askForPasswordDelay = 10;

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        FXPreferredViewStyle = "clmv";
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        ShowPathbar = true;
      };

      # Single Space spans all displays (turns OFF "Displays have separate
      # Spaces"). AeroSpace's recommended workaround for the macOS-API bug where
      # same-app windows across monitors (e.g. two Firefox windows) focus/raise
      # unpredictably. Trade-off: native multi-monitor fullscreen gets clunky —
      # irrelevant under tiling. Requires a logout to take effect.
      spaces.spans-displays = true;

      dock = {
        autohide = true;
        mru-spaces = false; # disable auto rearrange spaces based on most recent use
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        mineffect = "genie";
        orientation = "bottom";
        tilesize = 20;
        largesize = 65;
        magnification = true;
        minimize-to-application = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };

      WindowManager.EnableStandardClickToShowDesktop = false;
      controlcenter.BatteryShowPercentage = true;
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}

{ pkgs, config, ... }: {
    system = {
        defaults = {
            loginwindow.LoginwindowText = "";
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;

            finder = {
                AppleShowAllExtensions = true;
                AppleShowAllFiles = true;
                FXPreferredViewStyle = "clmv";
                _FXShowPosixPathInTitle = true;
                ShowPathbar = true;
            };

            dock = {
                autohide = false;
                mru-spaces = false; #disable auto rearrange spaces based on most recent use
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
        };
        
        keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
        };

    };

}
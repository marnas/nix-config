{ pkgs, config, ... }: {
    system = {
        defaults = {
            finder.AppleShowAllExtensions = true;
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.LoginwindowText = "";
            screencapture.location = "~/Pictures/screenshots";
            screensaver.askForPasswordDelay = 10;

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

        # This is used for showing linking system packages to Applications folder and show them with spotlight search
        activationScripts.postUserActivation.text = ''
            rsyncArgs="--archive --checksum --chmod=-w --copy-unsafe-links --delete"
            apps_source="${config.system.build.applications}/Applications"
            moniker="Nix Trampolines"
            app_target_base="$HOME/Applications"
            app_target="$app_target_base/$moniker"
            mkdir -p "$app_target"
            ${pkgs.rsync}/bin/rsync $rsyncArgs "$apps_source/" "$app_target"
        '';
    };

}
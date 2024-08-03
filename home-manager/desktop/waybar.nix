{ ... }: {

  programs.waybar = {
    enable = true;
    settings = [{
      height = 24;
      modules-left = [ "hyprland/workspaces" ];
      modules-right = [ "tray" "custom/separator" "pulseaudio" "custom/separator" "clock" ];
      "hyprland/workspaces" = {
        format = "{icon}";
        disable-scroll = true;
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "1";
          "7" = "2";
          "8" = "3";
          "9" = "4";
          "10" = "5";
        };
      };
      "custom/separator" = {
        format = "|";
        interval = "once";
        tooltip = "false";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-bluetooth = "{icon} {volume}% {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = "婢";
        format-icons = {
          headphone = "";
          default = [ "" "" "" ];
        };
        # on-click = pavucontrol;
        tooltip = false;
      };


      clock = {
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%a , %d %b %H:%M}";
        format-alt = "{:%H:%M}";
        interval = 1;
      };

      tray = {
        icon-size = 18;
        spacing = 7;
        tooltip = "false";
      };
    }];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Helvetica Neue;
      	/* Roboto */
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: #2d2a2e;
        color: #fcfcfa;
      }

      tooltip {
        background: rgba(43, 48, 59, 0.5);
        border: 1px solid rgba(100, 114, 125, 0.5);
      }

      tooltip label {
        color: white;
      }

      #workspaces button {
        box-shadow: none;
        min-height: 20px;
        border-radius: 0;
        text-shadow: none;
        border: none;
        padding: 1px;
        margin: 0;
        color: #fcfcfa;
      }

      window .modules-left #workspaces button.active:hover,
      window .modules-left #workspaces button.active {
        color: #fcfcfa;
        background-color: #285577;
      }

      window .modules-left #workspaces button:hover  {
        background: rgba(255, 255, 255, 0.00);
        color: #dddddd;
      }

      window .modules-right #custom-gpu-usage,
      window .modules-right #temperature,
      window .modules-right #pulseaudio,
      window .modules-right #clock{
        border: none;
        padding: 0 0;
        margin: 0 4;
      }

      window #custom-separator {
        color: #727072;
      }

      window #tray {
        margin: 0 5px;
      }
    '';
  };
}



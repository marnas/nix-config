{ pkgs
, ...
}:
let
  dpmsCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms";
  lockCommand = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --effect-blur 7x5 --fade-in 0.2 --font Roboto --font-size 20 -fF";
  # lockCommand = "${pkgs.swaylock}/bin/swaylock -fF";
in
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        # 10 minutes
        timeout = 600;
        command = "${lockCommand}";
      }
      {
        # 12 minutes
        timeout = 720;
        command = "${dpmsCommand} off";
        resumeCommand = "${dpmsCommand} on";
      }
      {
        # 15 minutes
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    # events = [
    #   {
    #     event = "before-sleep";
    #     command = "${lockCommand}";
    #   }
    #   {
    #     event = "lock";
    #     command = "${lockCommand}";
    #   }
    # ];
  };
}

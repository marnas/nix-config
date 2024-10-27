{ pkgs, ... }:
let
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";

  lockCommand =
    "${swaylock} --screenshots --effect-blur 7x5 --fade-in 0.2 --font Roboto --font-size 20 -f";
  dpmsCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms";

  isLocked = "${pgrep} -x ${swaylock}";
  lockTime = 10 * 60;
  # suspendTime = 5 * 60; # This is added on top of lockTime

  # Makes two timeouts: one for when the screen is not locked (lockTime+timeout) and one for when it is.
  afterLockTimeout = { timeout, command, resumeCommand ? null }: [
    {
      timeout = lockTime + timeout;
      inherit command resumeCommand;
    }
    {
      command = "${isLocked} && ${command}";
      inherit resumeCommand timeout;
    }
  ];
in {
  services.swayidle = {
    enable = true;
    timeouts = [{
      timeout = lockTime;
      command = "${lockCommand}";
    }] ++ (afterLockTimeout {
      timeout = 20;
      command = "${dpmsCommand} off";
      resumeCommand = "${dpmsCommand} on";
    });
    # ++ (afterLockTimeout {
    #      timeout = suspendTime;
    #      command = "${pkgs.systemd}/bin/systemctl suspend";
    #      resumeCommand = "${dpmsCommand} on";
    #    });
    events = [
      {
        event = "before-sleep";
        command = "${lockCommand}";
      }
      {
        event = "after-resume";
        command = "${dpmsCommand} on";
      }
    ];
  };
}

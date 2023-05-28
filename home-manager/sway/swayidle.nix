{ config, pkgs, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock -f";
  dpmsOn = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
  dpmsOff = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
in
{
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "after-resume";
        command = "systemctl restart --user kanshi.service && ${dpmsOn}";
      }
      {
        event = "before-sleep";
        command = swaylock;
      }
      {
        event = "lock";
        command = swaylock;
      }
    ];
    timeouts = [
      {
        timeout = 600;
        command = swaylock;
      }
      {
        timeout = 605;
        command = dpmsOff;
        resumeCommand = dpmsOn;
      }
    ];
  };
}

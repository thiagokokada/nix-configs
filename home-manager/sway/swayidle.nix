{ config, lib, pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "after-resume";
        command = ''systemctl restart --user kanshi.service && ${pkgs.sway}/bin/swaymsg "output * dpms on"'';
      }
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 605;
        command = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
        resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
      }
    ];
  };

  programs.swaylock.settings = {
    color = "000000";
    keyboard-layout = false;
  };
}

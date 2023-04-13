{ config, lib, pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    events = [
      { event = "after-resume"; command = "${pkgs.sway}/bin/swaymsg 'output * dpms on'"; }
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = [
      { timeout = 600; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { timeout = 605; command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'"; }
    ];
  };

  programs.swaylock.settings = {
    color = "000000";
    keyboard-layout = false;
  };
}

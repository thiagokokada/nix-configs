{ config, pkgs, lib, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock -f";
  notify = pkgs.writeShellScript "notify" ''
    ${pkgs.dunst}/bin/dunstify -t 30000 "30 seconds to lock"
  '';
  displayOn = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
  displayOff = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
in
{

  options.home-manager.desktop.sway.swayidle.enable = lib.mkEnableOption "swayidle config" // {
    default = config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.sway.swayidle.enable {
    services.swayidle = {
      enable = true;
      events = [
        {
          event = "after-resume";
          command = displayOn;
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
          timeout = 570;
          command = toString notify;
        }
        {
          timeout = 600;
          command = swaylock;
        }
        {
          timeout = 605;
          command = displayOff;
          resumeCommand = displayOn;
        }
      ];
    };
  };
}

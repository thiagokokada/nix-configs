{ config, pkgs, lib, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock -f";
  notify = pkgs.writeShellScript "notify" ''
    ${pkgs.dunst}/bin/dunstify -t 30000 "30 seconds to lock"
  '';
  dpmsOn = ''${pkgs.sway}/bin/swaymsg "output * dpms on"'';
  dpmsOff = ''${pkgs.sway}/bin/swaymsg "output * dpms off"'';
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
          command = dpmsOn;
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
          command = dpmsOff;
          resumeCommand = dpmsOn;
        }
      ];
    };
  };
}

{ config, pkgs, lib, ... }:

let
  swaylock = "${lib.getExe config.programs.swaylock.package} -f";
  notify = pkgs.writeShellScript "notify" ''
    ${lib.getExe' pkgs.dunst "dunstify"} -t 30000 "30 seconds to lock"
  '';
  displayOn = ''${lib.getExe' pkgs.sway "swaymsg"} "output * power on"'';
  displayOff = ''${lib.getExe' pkgs.sway "swaymsg"} "output * power off"'';
in
{

  options.home-manager.desktop.sway.swayidle.enable = lib.mkEnableOption "swayidle config" // {
    default = config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.sway.swayidle.enable {
    home.packages = with pkgs; [ swayidle ];

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

    # Add some time before restart, to avoid the following error:
    # swayidle.service: Start request repeated too quickly.
    systemd.user.services.swayidle.Service = {
      RestartSec = 5;
    };
  };
}

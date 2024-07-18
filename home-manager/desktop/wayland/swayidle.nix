{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.wayland.swayidle;
  swaylock = "${lib.getExe config.programs.swaylock.package} -f";
  notify = pkgs.writeShellScript "notify" ''
    ${lib.getExe' pkgs.dunst "dunstify"} -t 30000 "30 seconds to lock"
  '';
  displayOn = pkgs.writeShellScript "display-on" ''
    ${lib.getExe' pkgs.sway "swaymsg"} "output * power on" || true
    ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms on || true
  '';
  displayOff = pkgs.writeShellScript "display-off" ''
    ${lib.getExe' pkgs.sway "swaymsg"} "output * power off" || true
    ${lib.getExe' pkgs.hyprland "hyprctl"} dispatch dpms off || true
  '';
in
{
  options.home-manager.desktop.wayland.swayidle.enable = lib.mkEnableOption "swayidle config" // {
    default = config.home-manager.desktop.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ swayidle ];

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "after-resume";
          command = toString displayOn;
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
          command = toString displayOff;
          resumeCommand = toString displayOn;
        }
      ];
    };

    # Add some time before restart, to avoid the following error:
    # swayidle.service: Start request repeated too quickly.
    systemd.user.services.swayidle.Service = {
      # Use exponential restart
      RestartSteps = 5;
      RestartMaxDelaySec = 10;
    };
  };
}

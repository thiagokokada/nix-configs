{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.window-manager.wayland.swayidle;
  swaylock = "${lib.getExe config.programs.swaylock.package} -f";
  swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
  notify = toString (
    pkgs.writeShellScript "notify" ''
      ${lib.getExe pkgs.libnotify} -t 30000 "30 seconds to lock"
    ''
  );
  display =
    switch:
    toString (
      pkgs.writeShellScript "display-${switch}"
        # bash
        ''
          case "''${XDG_CURRENT_DESKTOP,,}" in
            sway)
              ${swaymsg} "output * power ${switch}"
              ;;
            *)
              >&2 echo "Unknown desktop environment: $XDG_CURRENT_DESKTOP"
              ;;
          esac
        ''
    );
in
{
  options.home-manager.window-manager.wayland.swayidle.enable =
    lib.mkEnableOption "swayidle config"
    // {
      default = config.home-manager.window-manager.wayland.enable;
    };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ swayidle ];

    services.swayidle = {
      enable = true;
      events = {
        after-resume = display "on";
        before-sleep = swaylock;
        lock = swaylock;
      };
      timeouts = [
        {
          timeout = 570;
          command = notify;
        }
        {
          timeout = 600;
          command = swaylock;
        }
        {
          timeout = 605;
          command = display "off";
          resumeCommand = display "on";
        }
      ];
    };

    systemd.user.services.swayidle = {
      Service = {
        inherit (config.home-manager.window-manager.systemd.service)
          RestartSec
          RestartSteps
          RestartMaxDelaySec
          ;
      };
    };
  };
}

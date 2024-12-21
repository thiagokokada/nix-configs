{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.wayland.swayidle;
  swaylock = "${lib.getExe config.programs.swaylock.package} -f";
  swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.finalPackage "hyprctl";
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
            hyprland)
              ${hyprctl} dispatch dpms ${switch}
              ;;
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
          command = display "on";
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

    # Add some time before restart, to avoid the following error:
    # swayidle.service: Start request repeated too quickly.
    systemd.user.services.swayidle.Service = {
      # Use exponential restart
      RestartSteps = 5;
      RestartMaxDelaySec = 10;
    };
  };
}

{ config, lib, pkgs, ... }:

{
  options.home-manager.desktop.i3.screen-locker.enable = lib.mkEnableOption "screen-locker config" // {
    default = config.home-manager.desktop.i3.enable;
  };

  config = lib.mkIf config.home-manager.desktop.i3.screen-locker.enable {
    services.screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = with config.home-manager.desktop.theme.fonts; toString
        (pkgs.writeShellScript "lock-screen" ''
          export XSECURELOCK_FORCE_GRAB=1
          export XSECURELOCK_BLANK_DPMS_STATE="off"
          export XSECURELOCK_DATETIME_FORMAT="%H:%M:%S - %a %d/%m"
          export XSECURELOCK_SHOW_DATETIME=1
          export XSECURELOCK_SHOW_HOSTNAME=0
          export XSECURELOCK_SHOW_USERNAME=0
          export XSECURELOCK_FONT="${gui.name}:style=Regular"

          exec ${lib.getExe pkgs.xsecurelock} $@
        '');
      # Use xss-lock instead
      xautolock.enable = false;
      xss-lock = {
        extraOptions =
          let
            notify = pkgs.writeShellScript "notify" ''
              ${lib.getExe' pkgs.dunst "dunstify"} -t 30000 "30 seconds to lock"
            '';
          in
          [
            "--notifier ${notify}"
            "--transfer-sleep-lock"
            "--session $XDG_SESSION_ID"
          ];
        screensaverCycle = 600;
      };
    };
  };
}

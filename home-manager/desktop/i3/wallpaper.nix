{ config, lib, pkgs, ... }:

{
  options.home-manager.desktop.i3.wallpaper.enable = lib.mkEnableOption "wallpaper config" // {
    default = config.home-manager.desktop.i3.enable;
  };

  config = lib.mkIf config.home-manager.desktop.i3.wallpaper.enable {
    systemd.user.services = {
      wallpaper = {
        Unit = {
          Description = "set wallpaper";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install.WantedBy = [ "graphical-session.target" ];

        Service = with config.home-manager.desktop.theme.wallpaper; {
          ExecStart = lib.concatStringsSep " " [
            "${lib.getExe pkgs.feh}"
            "--no-fehbg"
            "--bg-${scale}"
            "${path}"
          ];
          Type = "oneshot";
        };
      };
    };
  };
}

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

        Service = {
          ExecStart = lib.concatStringsSep " " [
            "${lib.getExe pkgs.feh}"
            "--no-fehbg"
            "--bg-${config.theme.wallpaper.scale}"
            "${config.theme.wallpaper.path}"
          ];
          Type = "oneshot";
        };
      };
    };
  };
}

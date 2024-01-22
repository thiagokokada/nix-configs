{ config, lib, pkgs, ... }:

{
  options.home-manager.desktop.twenty-twenty-twenty.enable = lib.mkEnableOption "twenty-twenty-twenty config" // {
    default = config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.desktop.twenty-twenty-twenty.enable {
    home.packages = with pkgs; [
      twenty-twenty-twenty
    ];

    systemd.user.services.twenty-twenty-twenty = {
      Unit = {
        BusName = "org.freedesktop.Notifications";
        Description = "Twenty-Twenty-Twenty";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        ExecStart = ''${lib.getExe pkgs.twenty-twenty-twenty} -disable-sound'';
        Type = "simple";
      };
    };
  };
}

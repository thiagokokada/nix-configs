{ config, lib, pkgs, ... }:

{
  services.mako = with config.theme.colors; {
    enable = true;
    font = with config.theme.fonts; "${gui.name} 12";
    backgroundColor = base00;
    textColor = base05;
    width = 200;
    borderSize = 1;
    borderColor = base01;
    defaultTimeout = 10000;
    padding = "8";
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      Documentation = "man:mako(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };
}

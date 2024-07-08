{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.home-manager.desktop.theme.gtk.enable = lib.mkEnableOption "GTK theme config" // {
    default = config.home-manager.desktop.theme.enable;
  };

  config = lib.mkIf config.home-manager.desktop.theme.gtk.enable {
    gtk = {
      enable = true;
      font = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      iconTheme = {
        package = pkgs.nordzy-icon-theme;
        name = "Nordzy-dark";
      };
      theme = {
        name = "Nordic-bluish-accent";
        package = pkgs.nordic;
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = with config; {
        # When running, most GNOME/GTK+ applications prefer those settings
        # instead of *.ini files
        "Net/IconThemeName" = gtk.iconTheme.name;
        "Net/ThemeName" = gtk.theme.name;
        "Gtk/CursorThemeName" = xsession.pointerCursor.name;
      };
    };
  };
}

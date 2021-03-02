{ config, pkgs, lib, ... }:

{
  theme = {
    fonts = {
      gui = {
        package = pkgs.roboto;
        name = "Roboto";
      };
    };

    colors = builtins.fromJSON (builtins.readFile ./colors.json);
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    with config.theme.fonts; [
      dejavu_fonts
      font-awesome_5
      gnome3.gnome-themes-standard
      gui.package
      hack-font
      hicolor-icon-theme
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

  systemd.user.services = {
    xsettingsd =
      let
        mkKeyValue = (k: v: ''${k} "${v}"'');
        configFile = with lib.generators;
          with config.gtk;
          with config.xsession;
          toKeyValue { mkKeyValue = mkKeyValue; } {
            "Net/IconThemeName" = "${iconTheme.name}";
            "Net/ThemeName" = "${theme.name}";
            "Gtk/CursorThemeName" = "${pointerCursor.name}";
          };
      in
      {
        Unit = {
          Description =
            "Provides settings to X11 applications via the XSETTINGS specification";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
        Service = {
          ExecStart = "${pkgs.kbdd}/bin/xsettingsd --config=${configFile}";
        };
      };
  };

  xsession.pointerCursor = {
    package = pkgs.gnome3.adwaita-icon-theme;
    name = "Adwaita";
    size = 32;
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };
}

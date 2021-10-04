{ config, pkgs, lib, ... }:

{
  # TODO: remove when HM 21.11 is released
  imports = [ ../modules/home-manager/xsettingsd.nix ];

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

  services.xsettingsd = {
    enable = true;
    settings = with config; {
      "Net/IconThemeName" = gtk.iconTheme.name;
      "Net/ThemeName" = gtk.theme.name;
      "Gtk/CursorThemeName" = xsession.pointerCursor.name;
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

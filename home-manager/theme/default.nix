{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/theme.nix
  ];

  theme = {
    fonts = {
      gui = {
        package = pkgs.roboto;
        name = "Roboto";
      };
    };
    colors = with builtins; fromJSON (readFile ./colors.json);
    wallpaper = pkgs.wallpapers.witch-hat-atelier_coco;
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      config.theme.fonts.gui.package
      dejavu_fonts
      font-awesome_5
      gnome.gnome-themes-extra
      hack-font
      hicolor-icon-theme
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    pointerCursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 32;
      x11.enable = true;
      gtk.enable = true;
    };
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

  # Export GTK configs, especially for GNOME4 applications
  services.xsettingsd = {
    enable = true;
    settings = with config; {
      "Net/IconThemeName" = gtk.iconTheme.name;
      "Net/ThemeName" = gtk.theme.name;
      "Gtk/CursorThemeName" = xsession.pointerCursor.name;
    };
  };
}

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
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs;
      with config.theme.fonts; [
        dejavu_fonts
        font-awesome_5
        gnome.gnome-themes-extra
        gui.package
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
}

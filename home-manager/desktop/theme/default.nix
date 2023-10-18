{ config, pkgs, lib, osConfig, ... }:

let
  cfg = config.home-manager.desktop.theme;
  themeType = lib.types.submodule {
    options = {
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        description = "Theme package";
      };

      name = lib.mkOption {
        type = with lib.types; either (listOf str) str;
        description = "Theme name";
      };
    };
  };
in
{
  imports = [
    ./gtk.nix
    ./qt.nix
  ];

  options.home-manager.desktop.theme = {
    enable = lib.mkEnableOption "theme config" // {
      default = config.home-manager.desktop.enable;
    };
    fonts = {
      gui = lib.mkOption {
        type = lib.types.nullOr themeType;
        description = "GUI font";
        default = {
          package = pkgs.roboto;
          name = "Roboto";
        };
      };

      icons = lib.mkOption {
        type = lib.types.nullOr themeType;
        description = "Icons font";
        default = {
          package = pkgs.font-awesome_6;
          name = [
            "Font Awesome 6 Brands"
            "Font Awesome 6 Free Solid"
          ];
        };
      };

      symbols = lib.mkOption {
        type = lib.types.nullOr themeType;
        description = "Symbols font";
        default = {
          package = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
          name = "Hack Nerd Font";
        };
      };

      dpi = lib.mkOption {
        type = lib.types.int;
        description = "Font dpi";
        default = 135;
      };
    };

    colors = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Base16 colors";
      default = lib.importJSON ./colors.json;
    };

    wallpaper = {
      path = lib.mkOption {
        type = lib.types.path;
        description = "Wallpaper path";
        default = pkgs.wallpapers.hatsune-miku_walking-4k;
      };
      scale = lib.mkOption {
        type = lib.types.enum [ "tile" "center" "fill" "scale" ];
        default = "fill";
        description = "Wallpaper scaling";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable fonts in home.packages to be available to applications
    fonts.fontconfig.enable = true;

    home = {
      packages = with pkgs; with cfg; [
        dejavu_fonts
        fonts.gui.package
        fonts.icons.package
        fonts.symbols.package
        gnome.gnome-themes-extra
        hack-font
        hicolor-icon-theme
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];

      pointerCursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
        size = 24;
        x11.enable = true;
        gtk.enable = true;
      };
    };

    # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
    dconf.settings = lib.mkIf (osConfig ? fonts.fontconfig) {
      "org/gnome/desktop/interface" = with osConfig.fonts.fontconfig; {
        "color-scheme" = "prefer-dark";
        "font-antialiasing" =
          if antialias then
            if (subpixel.rgba == "none")
            then "grayscale"
            else "rgba"
          else "none";
        "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting.style;
        "font-rgba-order" = subpixel.rgba;
      };
    };

    services.xsettingsd = lib.mkIf (osConfig ? fonts.fontconfig) {
      enable = true;
      settings = {
        # Applications like Java/Wine doesn't use Fontconfig settings,
        # but uses it from here
        "Xft/Antialias" = osConfig.fonts.fontconfig.antialias;
        "Xft/Hinting" = osConfig.fonts.fontconfig.hinting.enable;
        "Xft/HintStyle" = osConfig.fonts.fontconfig.hinting.style;
        "Xft/RGBA" = osConfig.fonts.fontconfig.subpixel.rgba;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.desktop.theme.fonts;
  fontType = lib.types.submodule {
    options = {
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        description = "Font package.";
      };
      name = lib.mkOption {
        type = with lib.types; either (listOf str) str;
        description = "Font name.";
      };
    };
  };
in
{
  options.home-manager.desktop.theme.fonts = {
    enable = lib.mkEnableOption "font config" // {
      default = config.home-manager.desktop.theme.enable;
    };

    dpi = lib.mkOption {
      type = lib.types.int;
      description = "Font dpi.";
      default = 135;
    };

    gui = lib.mkOption {
      type = lib.types.nullOr fontType;
      description = "GUI font.";
      default = {
        package = pkgs.roboto;
        name = "Roboto";
      };
    };

    icons = lib.mkOption {
      type = lib.types.nullOr fontType;
      description = "Icons font.";
      default = {
        package = pkgs.font-awesome_6;
        name = [
          "Font Awesome 6 Brands"
          "Font Awesome 6 Free Solid"
        ];
      };
    };

    symbols = lib.mkOption {
      type = lib.types.nullOr fontType;
      description = "Symbols font.";
      default = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };
    };

    fontconfig = {
      enable = lib.mkEnableOption "Fontconfig config" // {
        default = osConfig.fonts.fontconfig.enable or false;
      };
      antialias = lib.mkEnableOption "antialias" // {
        default = osConfig.fonts.fontconfig.antialias or true;
      };
      hinting = {
        enable = lib.mkEnableOption "hinting" // {
          default = osConfig.fonts.fontconfig.hinting.enable or true;
        };
        style = lib.mkOption {
          type = lib.types.enum [
            "none"
            "slight"
            "medium"
            "full"
          ];
          default = osConfig.fonts.fontconfig.hinting.style or "slight";
        };
      };
      subpixel = {
        rgba = lib.mkOption {
          default = osConfig.fonts.fontconfig.hinting.subpixel.rgba or "none";
          type = lib.types.enum [
            "rgb"
            "bgr"
            "vrgb"
            "vbgr"
            "none"
          ];
          description = "Subpixel order";
        };
        lcdfilter = lib.mkOption {
          default = osConfig.fonts.fontconfig.subpixel.lcdfilter or "default";
          type = lib.types.enum [
            "none"
            "default"
            "light"
            "legacy"
          ];
          description = "LCD filter";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable fonts in home.packages to be available to applications
    fonts.fontconfig.enable = true;

    home.packages =
      with pkgs;
      with cfg;
      [
        dejavu_fonts
        gnome-themes-extra
        gui.package
        hack-font
        hicolor-icon-theme
        icons.package
        liberation_ttf
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        symbols.package
      ];

    # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
    dconf.settings = lib.mkIf cfg.fontconfig.enable {
      "org/gnome/desktop/interface" = with cfg.fontconfig; {
        "color-scheme" = "prefer-dark";
        "font-antialiasing" =
          if antialias then if (subpixel.rgba == "none") then "grayscale" else "rgba" else "none";
        "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting.style;
        "font-rgba-order" = subpixel.rgba;
      };
    };

    services.xsettingsd = lib.mkIf cfg.fontconfig.enable {
      enable = true;
      settings = {
        # Applications like Java/Wine doesn't use Fontconfig settings,
        # but uses it from here
        "Xft/Antialias" = cfg.fontconfig.antialias;
        "Xft/Hinting" = cfg.fontconfig.hinting.enable;
        "Xft/HintStyle" = cfg.fontconfig.hinting.style;
        "Xft/RGBA" = cfg.fontconfig.subpixel.rgba;
      };
    };

    systemd.user.services.xsettingsd = {
      Service = {
        # Exponential restart
        RestartSteps = 5;
        RestartMaxDelaySec = 10;
        Restart = lib.mkForce "on-failure";
      };
    };
  };
}

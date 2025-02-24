{
  config,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.desktop.theme.fonts.fontconfig;
in
{
  options.home-manager.desktop.theme.fonts.fontconfig = {
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

  config = lib.mkIf cfg.enable {
    # Enable fonts in home.packages to be available to applications
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Noto Sans Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
    dconf.settings = {
      "org/gnome/desktop/interface" = with cfg; {
        "color-scheme" = "prefer-dark";
        "font-antialiasing" =
          if antialias then if (subpixel.rgba == "none") then "grayscale" else "rgba" else "none";
        "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting.style;
        "font-rgba-order" = subpixel.rgba;
      };
    };

    services.xsettingsd = {
      enable = true;
      settings = {
        # Applications like Java/Wine doesn't use Fontconfig settings,
        # but uses it from here
        "Xft/Antialias" = cfg.antialias;
        "Xft/Hinting" = cfg.hinting.enable;
        "Xft/HintStyle" = cfg.hinting.style;
        "Xft/RGBA" = cfg.subpixel.rgba;
      };
    };

    systemd.user.services.xsettingsd = {
      Service = {
        inherit (config.home-manager.desktop.systemd.service) RestartSec RestartSteps RestartMaxDelaySec;
        Restart = lib.mkForce "on-failure";
      };
    };
  };
}

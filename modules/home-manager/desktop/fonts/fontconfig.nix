{ config, lib, ... }:

let
  cfg = config.home-manager.desktop.fonts.fontconfig;
in
{
  options.home-manager.desktop.fonts.fontconfig = {
    enable = lib.mkEnableOption "Fontconfig config" // {
      default = config.home-manager.desktop.fonts.enable;
    };

    antialias = lib.mkEnableOption "antialias";

    hinting = {
      enable = lib.mkEnableOption "hinting";
      autohint = lib.mkEnableOption "autohint";
      style = lib.mkOption {
        type = lib.types.enum [
          "none"
          "slight"
          "medium"
          "full"
        ];
        default = "none";
      };
    };

    subpixel = {
      rgba = lib.mkOption {
        default = "none";
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
        default = "default";
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

  config = lib.mkMerge [
    {
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
    }
    (lib.mkIf config.home-manager.window-manager.enable {
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
          inherit (config.home-manager.window-manager.systemd.service)
            RestartSec
            RestartSteps
            RestartMaxDelaySec
            ;
          Restart = lib.mkForce "on-failure";
        };
      };
    })
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.desktop.fonts.fontconfig;
  cfgFc = config.fonts.fontconfig;
in
{
  options.home-manager.desktop.fonts.fontconfig = {
    enable = lib.mkEnableOption "Fontconfig config" // {
      default = config.home-manager.desktop.fonts.enable;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];

      fonts.fontconfig = {
        # Enable fonts in home.packages to be available to applications
        enable = true;
        defaultFonts = {
          monospace = [ "Noto Sans Mono" ];
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && config.home-manager.window-manager.enable) {
      # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
      dconf.settings = {
        "org/gnome/desktop/interface" = with cfgFc; {
          "color-scheme" = "prefer-dark";
          "font-antialiasing" =
            if antialiasing then if (subpixelRendering == "none") then "grayscale" else "rgba" else "none";
          "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting;
          "font-rgba-order" = subpixelRendering;
        };
      };

      services.xsettingsd = {
        enable = true;
        settings = {
          # Applications like Java/Wine doesn't use Fontconfig settings,
          # but uses it from here
          "Xft/Antialias" = cfgFc.antialiasing;
          "Xft/Hinting" = cfgFc.hinting != null;
          "Xft/HintStyle" = cfgFc.hinting;
          "Xft/RGBA" = cfgFc.subpixelRendering;
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

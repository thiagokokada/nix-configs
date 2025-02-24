{
  config,
  pkgs,
  lib,
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
  imports = [ ./fontconfig.nix ];

  options.home-manager.desktop.theme.fonts = {
    enable = lib.mkEnableOption "font config" // {
      default = config.home-manager.desktop.theme.enable || config.home-manager.darwin.enable;
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
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      with cfg;
      [
        gui.package
        icons.package
        symbols.package
        # Noto fonts is a good fallback font
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
  };
}

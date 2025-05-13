{ pkgs, lib, ... }:

let
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
  options.theme.fonts = {
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
        name = "Hack Nerd Font Mono";
      };
    };
  };
}

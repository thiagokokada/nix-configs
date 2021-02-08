{ pkgs, lib, ... }:

with lib;
let
  themeType = types.submodule {
    options = {
      package = mkOption {
        type = with types; nullOr package;
        description = "GTK theme";
      };

      name = mkOption {
        type = types.str;
        description = "GTK theme name";
      };
    };
  };
in {
  options.theme = {
    fonts = {
      gui = mkOption {
        type = types.nullOr themeType;
        description = "GUI main font";
      };
    };

    colors = mkOption {
      type = with types; attrsOf str;
      description = "Base16 colors";
    };
  };
}

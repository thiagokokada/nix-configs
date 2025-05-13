{ pkgs, lib, ... }:

{
  imports = [ ./fonts.nix ];

  options.theme = {
    colors = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Base16 colors.";
      default = lib.importJSON ./colors.json;
    };

    wallpaper = {
      path = lib.mkOption {
        type = lib.types.path;
        description = "Wallpaper path.";
        default = pkgs.wallpapers.hatsune-miku_walking-4k;
      };
      scale = lib.mkOption {
        type = lib.types.enum [
          "tile"
          "center"
          "fill"
          "scale"
        ];
        default = "fill";
        description = "Wallpaper scaling.";
      };
    };
  };
}

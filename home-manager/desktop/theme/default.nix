{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.theme;
in
{
  imports = [
    ./fonts.nix
    ./gtk.nix
    ./qt.nix
  ];

  options.home-manager.desktop.theme = {
    enable = lib.mkEnableOption "theme config" // {
      default = config.home-manager.desktop.enable;
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
        type = lib.types.enum [
          "tile"
          "center"
          "fill"
          "scale"
        ];
        default = "fill";
        description = "Wallpaper scaling";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      pointerCursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-cursors";
        size = 24;
        x11.enable = true;
        gtk.enable = true;
      };
    };
  };
}

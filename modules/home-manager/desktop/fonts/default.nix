{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.fonts;
in
{
  imports = [ ./fontconfig.nix ];

  options.home-manager.desktop.fonts = {
    enable = lib.mkEnableOption "font config" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      with config.theme.fonts;
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

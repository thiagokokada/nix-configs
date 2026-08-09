{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.window-manager.theme;
in
{
  imports = [
    ./gtk.nix
    ./qt.nix
  ];

  options.home-manager.window-manager.theme = {
    enable = lib.mkEnableOption "theme config" // {
      default = config.home-manager.window-manager.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      enable = true;
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}

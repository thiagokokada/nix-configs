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
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 32;
      x11.enable = true;
      gtk.enable = true;
    };
  };
}

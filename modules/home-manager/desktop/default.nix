{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.desktop;
in
{
  imports = [
    ./chromium.nix
    ./easyeffects
    ./firefox.nix
    ./fonts
    ./kitty.nix
    ./mpv
    ./nixgl.nix
  ];

  options.home-manager.desktop = {
    enable = lib.mkEnableOption "desktop config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      audacious
      libreoffice-stable
      (mcomix.override { unrarSupport = true; })
    ];
  };
}

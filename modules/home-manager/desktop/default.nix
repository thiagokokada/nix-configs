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
    ./firefox.nix
    ./fonts
    ./ghostty.nix
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
      calibre
      libreoffice-fresh
      (mcomix.override { unrarSupport = true; })
    ];
  };
}

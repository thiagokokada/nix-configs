{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.window-manager;
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
      android-file-transfer
      audacious
      libreoffice-fresh
      (mcomix.override { unrarSupport = true; })
    ];
  };
}

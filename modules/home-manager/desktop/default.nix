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
      corefonts # needed for onlyoffice
      onlyoffice-bin
      (mcomix.override { unrarSupport = true; })
    ];
  };
}

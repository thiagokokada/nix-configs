{
  config,
  lib,
  pkgs,
  osConfig,
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
    ./kitty.nix
    ./mpv
    ./nixgl.nix
    ./xterm.nix
  ];

  options.home-manager.desktop = {
    enable = lib.mkEnableOption "desktop config" // {
      default = osConfig.nixos.desktop.enable or false;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      android-file-transfer
      audacious
      libreoffice-fresh
      (mcomix.override {
        unrarSupport = true;
        pdfSupport = false;
      })
    ];
  };
}

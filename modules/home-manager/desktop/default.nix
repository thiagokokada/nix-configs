{ lib, osConfig, ... }:

{
  imports = [
    ./chromium.nix
    ./firefox.nix
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
}

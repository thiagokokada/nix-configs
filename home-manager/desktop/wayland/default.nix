{ config, lib, ... }:

{
  imports = [
    ./fuzzel.nix
    ./hyprland
    ./kanshi
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  options.home-manager.desktop.wayland.enable = lib.mkEnableOption "Wayland config" // {
    default = config.home-manager.desktop.enable;
  };
}

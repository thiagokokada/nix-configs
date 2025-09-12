{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./fuzzel.nix
    ./kanshi
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  options.home-manager.window-manager.wayland.enable = lib.mkEnableOption "Wayland config" // {
    default = config.home-manager.window-manager.enable;
  };

  config = lib.mkIf config.home-manager.window-manager.wayland.enable {
    home.packages = with pkgs; [
      waypipe
      wdisplays
      wl-clipboard
    ];
  };
}

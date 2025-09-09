{ config, lib, ... }:

{
  imports = [
    ./greetd.nix
    ./wayland.nix
    ./xserver.nix
  ];

  options.nixos.window-manager.enable = lib.mkEnableOption "window-manager config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
    ];
  };

  config = lib.mkIf config.nixos.window-manager.enable {
    # Programs that needs system-wide permissions to work correctly
    programs = {
      gnome-disks.enable = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;
      graphical-desktop.enable = true;
      udisks2.enable = true;
    };
  };
}

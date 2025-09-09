{ config, lib, ... }:

{
  imports = [
    ./greetd.nix
    ./wayland.nix
    ./xserver.nix
  ];

  options.nixos.desktop.window-manager.enable = lib.mkEnableOption "window-manager config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
    ];
  };

  config = lib.mkIf config.nixos.desktop.enable {
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

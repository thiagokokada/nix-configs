{ config, lib, ... }:

{
  imports = [
    ./greetd.nix
    ./plymouth.nix
    ./wayland.nix
    ./xserver.nix
  ];

  options.nixos.desktop.enable = lib.mkDefaultOption "desktop config";

  config = lib.mkIf config.nixos.desktop.enable {
    programs.gnome-disks.enable = true;

    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
    };
  };
}

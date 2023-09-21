{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./greetd.nix
    ./locale.nix
    ./plymouth.nix
    ./tailscale.nix
    ./wayland.nix
    ./xserver.nix
  ];

  options.nixos.desktop.enable = lib.mkEnableOption "desktop config";

  config = lib.mkIf config.nixos.desktop.enable {
    programs.gnome-disks.enable = true;

    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
    };
  };
}

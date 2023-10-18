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

  options.nixos.desktop.enable = lib.mkEnableOption "desktop config" // {
    default = builtins.any (x: config.device.type == x) [ "desktop" "laptop" ];
  };

  config = lib.mkIf config.nixos.desktop.enable {
    programs.gnome-disks.enable = true;

    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      # Reduces power consumption on demand
      # TODO: use it in place of TLP?
      power-profiles-daemon.enable = !config.nixos.laptop.tlp.enable;
      udisks2.enable = true;
    };
  };
}

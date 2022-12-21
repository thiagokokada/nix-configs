{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.enable = pkgs.lib.mkDefaultOption "desktop config";

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [ smartmontools ];

    programs.gnome-disks.enable = true;
    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
    };

    xdg = {
      # For sway screensharing
      # https://nixos.wiki/wiki/Firefox
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };
    };
  };
}

{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.enable = pkgs.lib.mkDefaultOption "desktop config";

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [
      hdparm
      smartmontools
    ];

    programs.gnome-disks.enable = true;
    services = {
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
    };

    # For sway screensharing
    # https://nixos.wiki/wiki/Firefox
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      # Always use portal with xdg-open
      xdgOpenUsePortal = true;
      # Allow for screensharing in wlroots-based desktop
      wlr.enable = true;
    };
  };
}

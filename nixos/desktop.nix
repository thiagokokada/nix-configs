{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.enable = lib.mkEnableOption "desktop config" // { default = true; };

  config = lib.mkIf config.nixos.desktop.enable {
    environment.systemPackages = with pkgs; [ smartmontools ];

    programs.gnome-disks.enable = true;

    services = {
      smartd = {
        enable = true;
        notifications.x11.enable = true;
      };
      gnome = {
        gnome-keyring.enable = true;
        sushi.enable = true;
      };
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
        gtkUsePortal = true;
      };
    };
  };
}

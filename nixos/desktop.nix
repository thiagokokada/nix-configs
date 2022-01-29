{ pkgs, config, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [ ./audio.nix ];

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
}

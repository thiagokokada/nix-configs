{ pkgs, config, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [ ./audio.nix ];

  programs.gnome-disks.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;
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

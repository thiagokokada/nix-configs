{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.wayland.enable = lib.mkDefaultOption "wayland config";

  config = lib.mkIf config.nixos.desktop.wayland.enable {
    programs.sway = {
      # Make Sway available for display managers
      enable = true;
      # Remove unnecessary packages from system-wide install (e.g.: foot)
      extraPackages = [ ];
    };

    # For sway screensharing
    # https://nixos.wiki/wiki/Firefox
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      # Allow for screensharing in wlroots-based desktop
      wlr.enable = true;
    };
  };
}

{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.wayland.enable = lib.mkEnableOption "wayland config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.wayland.enable {
    programs.sway = {
      # Make Sway available for display managers and make things like swaylock work
      enable = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      # Remove unnecessary packages from system-wide install (e.g.: foot)
      extraPackages = [ ];
    };

    # https://github.com/swaywm/sway/pull/6994
    security.wrappers.sway = {
      owner = "root";
      group = "root";
      source = "${config.programs.sway.package}/bin/sway";
      capabilities = "cap_sys_nice+ep";
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

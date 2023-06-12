{ pkgs, ... }:

{
  programs.sway = {
    # Make Sway available for display managers
    enable = true;
    # Remove unnecessary packages from system-wide install (e.g.: foot)
    package = null;
    extraPackages = [ ];
  };

  # For sway screensharing
  # https://nixos.wiki/wiki/Firefox
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
    ];
    # Allow for screensharing in wlroots-based desktop
    wlr.enable = true;
  };
}

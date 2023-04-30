{ config, lib, pkgs, ... }:

{
  # Enable PAM integration necessary for e.g.: swaylock
  programs.sway.enable = true;
  xdg.portal = {
    enable = true;
    # Always use portal with xdg-open
    xdgOpenUsePortal = true;
    # Allow for screensharing in wlroots-based desktop
    wlr.enable = true;
  };
}

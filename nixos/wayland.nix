{ config, lib, pkgs, ... }:

{
  # Enable PAM integration necessary for e.g.: swaylock
  programs.sway.enable = true;
}

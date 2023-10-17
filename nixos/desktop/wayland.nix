{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.wayland.enable = lib.mkEnableOption "wayland config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.wayland.enable {
    programs.sway = {
      # Make Sway available for display managers and make things like swaylock work
      enable = true;
      # Disable Sway package (will use HM one instead)
      package = null;
      # Remove unnecessary packages from system-wide install (e.g.: foot)
      extraPackages = [ ];
    };

    # https://github.com/NixOS/nixpkgs/pull/207842#issuecomment-1374906499
    security.pam.loginLimits = [
      { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
    ];

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

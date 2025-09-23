{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.window-manager.wayland;
in
{
  options.nixos.window-manager.wayland = {
    sway.enable = lib.mkEnableOption "Sway config" // {
      default = config.nixos.window-manager.enable;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.sway.enable {
      nixos.home.extraModules = {
        home-manager.window-manager.wayland.sway.enable = true;
      };

      programs = {
        sway = {
          # Make Sway available for display managers and make things like swaylock work
          inherit (cfg.sway) enable;
          # Do not add this to display managers (we will add via UWSM)
          package = null;
          # Remove unnecessary packages from system-wide install (e.g.: foot)
          extraPackages = [ ];
        };
        uwsm = {
          enable = true;
          waylandCompositors.sway = lib.mkIf cfg.sway.enable {
            prettyName = "Sway";
            comment = "Sway compositor managed by UWSM";
            binPath = "/etc/profiles/per-user/${config.nixos.home.username}/bin/sway";
          };
        };
      };

      # https://github.com/NixOS/nixpkgs/pull/207842#issuecomment-1374906499
      security.pam.loginLimits = [
        {
          domain = "@users";
          item = "rtprio";
          type = "-";
          value = 1;
        }
      ];

      # For sway screensharing
      # https://nixos.wiki/wiki/Firefox
      xdg.portal = lib.mkIf cfg.sway.enable {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
        # Allow for screensharing in wlroots-based desktop
        wlr.enable = true;
      };
    })
  ];
}

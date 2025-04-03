{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.desktop.wayland.enable = lib.mkEnableOption "wayland config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.wayland.enable {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
      sway = {
        # Make Sway available for display managers and make things like swaylock work
        enable = true;
        # Do not add this to display managers (we will add via UWSM)
        package = null;
        # Remove unnecessary packages from system-wide install (e.g.: foot)
        extraPackages = [ ];
      };
      uwsm = {
        enable = true;
        waylandCompositors.sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "/etc/profiles/per-user/${config.meta.username}/bin/sway";
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
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      # Allow for screensharing in wlroots-based desktop
      wlr.enable = true;
    };
  };
}

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
    niri.enable = lib.mkEnableOption "Niri config" // {
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
    (lib.mkIf cfg.niri.enable {
      nixos.home.extraModules = {
        home-manager.window-manager.wayland.niri.enable = true;
      };

      programs = {
        # Manage the session with uwsm, so we can't use upstream module
        # niri.enable = true;
        uwsm = {
          enable = true;
          waylandCompositors.niri = {
            prettyName = "Niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/niri-session";
          };
        };
      };

      # Copy of the upstream module
      environment.systemPackages = [
        pkgs.niri
      ];

      # Required for xdg-desktop-portal-gnome's FileChooser to work properly
      services.dbus.packages = [
        pkgs.nautilus
      ];

      services = {
        # Recommended by upstream
        # https://github.com/YaLTeR/niri/wiki/Important-Software#portals
        gnome.gnome-keyring.enable = lib.mkDefault true;
      };

      systemd.packages = [ pkgs.niri ];

      xdg.portal = {
        enable = true;

        # NOTE: `configPackages` is ignored when `xdg.portal.config.niri` is defined.
        config.niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          # "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };

        # Recommended by upstream, required for screencast support
        # https://github.com/YaLTeR/niri/wiki/Important-Software#portals
        extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      };
    })
  ];
}

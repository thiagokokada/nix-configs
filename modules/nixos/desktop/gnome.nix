{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.desktop.gnome;
in
{
  options.nixos.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME config";
  };

  config = lib.mkIf cfg.enable {
    nixos.home.extraModules = {
      home-manager.desktop.gnome.enable = true;
    };

    environment.systemPackages = with pkgs; [
      dconf-editor
      gnome-tweaks
      # Qt: themes the app titlebars
      qadwaitadecorations
      qadwaitadecorations-qt6
      # Qt: themes the apps
      qgnomeplatform
      qgnomeplatform-qt6
    ];

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
    ];

    services = {
      desktopManager.gnome = {
        enable = true;
      };
      displayManager = {
        defaultSession = lib.mkDefault "gnome";
        gdm.enable = lib.mkDefault true;
      };

      gnome = {
        gnome-keyring.enable = true;
        # Who really cares about GNOME games?
        games.enable = false;
      };
    };

    # GNOME's power menu always requests a regular suspend. On laptops,
    # redirect that request to systemd's suspend-then-hibernate operation.
    systemd.services.systemd-suspend = lib.mkIf config.nixos.laptop.enable {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "${config.systemd.package}/lib/systemd/systemd-sleep suspend-then-hibernate"
      ];
    };
  };
}

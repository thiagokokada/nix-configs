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

      # Who really cares about GNOME games?
      gnome.games.enable = false;
    };
  };
}

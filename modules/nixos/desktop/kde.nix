{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.desktop.kde;
in
{
  options.nixos.desktop.kde = {
    enable = lib.mkEnableOption "KDE config" // {
      default = config.device.type == "steam-machine";
    };
    sddm.enable = lib.mkEnableOption "KDE config" // {
      default = config.device.type != "steam-machine";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        kdePackages.kcalc
        kdePackages.kcharselect
        kdePackages.kclock
        kdePackages.kcolorchooser
        kdePackages.kolourpaint
        kdePackages.ksystemlog
        kdiskmark
      ]
      ++ lib.optionals cfg.sddm.enable [
        kdePackages.sddm-kcm
      ]
      ++ lib.optionals config.services.flatpak.enable [
        kdePackages.discover
      ]
      ++ lib.optionals config.services.smartd.enable [
        kdePackages.plasma-disks
      ];

    programs.kdeconnect.enable = true;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = "plasma";
        sddm = {
          inherit (cfg.sddm) enable;
          wayland.enable = cfg.sddm.enable;
        };
      };
    };
  };
}

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
        kdePackages.sddm-kcm
        kdiskmark
      ]
      ++ lib.optionals config.services.flatpak.enable [
        kdePackages.discover
      ]
      ++ lib.optionals config.services.smartd.enable [
        kdePackages.plasma-disks
      ];

    jovian.steam.desktopSession = "plasma";

    programs.kdeconnect.enable = true;

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        defaultSession = lib.mkDefault "plasma";
        sddm = {
          enable = lib.mkDefault true;
          wayland.enable = lib.mkDefault true;
        };
      };
    };
  };
}

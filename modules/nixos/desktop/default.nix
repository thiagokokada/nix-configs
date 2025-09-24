{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./kde.nix
    ./locale.nix
    ./plymouth.nix
    ./tailscale.nix
    ./wireless.nix
  ];

  options.nixos.desktop.enable = lib.mkEnableOption "desktop config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
      "steam-machine"
    ];
  };

  config = lib.mkIf config.nixos.desktop.enable {
    nixos.home.extraModules = {
      home-manager.desktop.enable = true;
    };

    # Increase file handler limit
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "nofile";
        value = "524288";
      }
    ];

    systemd = {
      settings.Manager = {
        # Reduce default service stop timeouts for faster shutdown
        DefaultTimeoutStopSec = lib.mkDefault "15s";
      };
      services."user@".serviceConfig = {
        # Reduce default service stop for User services
        TimeoutStopSec = lib.mkDefault "15s";
      };
    };

    services = {
      dbus.implementation = "broker";
      flatpak.enable = true;
    };
  };
}

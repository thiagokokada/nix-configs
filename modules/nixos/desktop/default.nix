{
  config,
  lib,
  libEx,
  ...
}:

{
  imports = [
    ./audio.nix
    ./calibre.nix
    ./chromium.nix
    ./fonts.nix
    ./kde.nix
    ./keyboard.nix
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

    programs.gnome-disks.enable = true;

    # Increase file handler limit
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "nofile";
        value = "524288";
      }
    ];

    # Calibre server
    networking.firewall = {
      allowedTCPPorts = [ 9090 ];
      allowedUDPPorts = [
        54982
        48123
        39001
        44044
        59678
      ];
    };

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
      flatpak.enable = true;
      scx = {
        enable = true;
        scheduler = "scx_lavd";
      };
    };

    # https://github.com/Jovian-Experiments/Jovian-NixOS/blob/d15853dadb69837bc1e86c5be52c1e6b4bda3da4/modules/steam/steam.nix#L64
    systemd.services.scx.wantedBy = libEx.mkLocalForce [ "multi-user.target" ];
  };
}

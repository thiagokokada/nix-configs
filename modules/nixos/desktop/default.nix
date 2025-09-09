{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./greetd.nix
    ./locale.nix
    ./tailscale.nix
    ./window-manager
    ./wireless.nix
  ];

  options.nixos.desktop.enable = lib.mkEnableOption "desktop config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
    ];
  };

  config = lib.mkIf config.nixos.desktop.enable {
    # Enable graphical boot
    boot.plymouth.enable = lib.mkDefault true;

    # Increase file handler limit
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "nofile";
        value = "524288";
      }
    ];

    services.dbus.implementation = "broker";
  };
}

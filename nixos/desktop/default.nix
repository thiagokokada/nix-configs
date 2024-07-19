{ config, lib, ... }:

{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./greetd.nix
    ./locale.nix
    ./non-nix.nix
    ./tailscale.nix
    ./wayland.nix
    ./xserver.nix
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

    # Gnome Disks needs system-wide permissions to work correctly
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

    services = {
      dbus.implementation = "broker";
      # Gnome Keyring/Udisks 2 needs system-wide permissions to work correctly
      gnome.gnome-keyring.enable = true;
      udisks2.enable = true;
    };
  };
}

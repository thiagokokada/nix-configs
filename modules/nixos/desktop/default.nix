{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.mainUser) username;
in
{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./greetd.nix
    ./locale.nix
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

    # Programs that needs system-wide permissions to work correctly
    programs = {
      adb.enable = true;
      gnome-disks.enable = true;
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

    services = {
      ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
      dbus.implementation = "broker";
      gnome.gnome-keyring.enable = true;
      graphical-desktop.enable = true;
      udisks2.enable = true;
    };

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

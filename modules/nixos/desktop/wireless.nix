{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nixos.desktop.wireless;
in
{
  options.nixos.desktop.wireless = {
    enable = lib.mkEnableOption "Wi-Fi/Bluetooth config" // {
      default = config.nixos.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Wireless related packages
    environment.systemPackages = with pkgs; [ iw ];

    programs.nm-applet.enable = lib.mkDefault config.nixos.window-manager.enable;

    networking = {
      # Use Network Manager
      networkmanager = {
        enable = true;
        wifi.backend = lib.mkDefault "iwd";
      };
    };

    # Enable bluetooth
    hardware.bluetooth.enable = true;

    # Enable Blueman to manage Bluetooth
    services.blueman.enable = config.nixos.window-manager.enable;

    users.users.${config.nixos.home.username}.extraGroups = [ "networkmanager" ];
  };
}

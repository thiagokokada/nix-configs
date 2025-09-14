{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.nixos.desktop.wireless.enable = lib.mkEnableOption "Wi-Fi/Bluetooth config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.enable {
    # Install Wireless related packages
    environment.systemPackages = with pkgs; [ iw ];

    networking = {
      # Use Network Manager
      networkmanager = {
        enable = true;
        wifi.backend = lib.mkDefault "iwd";
      };
    };

    # Enable bluetooth
    hardware.bluetooth.enable = true;
  };
}

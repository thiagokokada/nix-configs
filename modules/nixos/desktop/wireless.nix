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

    # Enable Blueman to manage Bluetooth
    services.blueman.enable = config.nixos.window-manager.enable;

    users.users.${config.nixos.home.username}.extraGroups = [ "networkmanager" ];
  };
}

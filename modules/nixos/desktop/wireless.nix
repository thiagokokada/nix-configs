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
    networking = {
      # Use Network Manager
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    };

    # Install Wireless related packages
    environment.systemPackages = with pkgs; [ iw ];

    # Enable bluetooth
    hardware.bluetooth.enable = true;

    # Enable NetworkManager applet
    programs.nm-applet.enable = true;

    # Make nm-applet restart in case of failure
    systemd.user.services.nm-applet = {
      serviceConfig = {
        # Use exponential restart
        RestartSteps = 5;
        RestartMaxDelaySec = 10;
        Restart = "on-failure";
      };
    };

    # Enable Blueman to manage Bluetooth
    services.blueman.enable = true;
  };
}

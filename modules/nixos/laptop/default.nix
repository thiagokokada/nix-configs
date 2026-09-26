{ config, lib, ... }:

{
  options.nixos.laptop.enable = lib.mkEnableOption "laptop config" // {
    default = config.device.type == "laptop";
  };

  config = lib.mkIf config.nixos.laptop.enable {
    # Configure hibernation
    boot.resumeDevice = lib.mkIf (config.swapDevices != [ ]) (
      lib.mkDefault (builtins.head config.swapDevices).device
    );

    # Enable laptop specific services
    services = {
      logind = {
        settings.Login = {
          HandlePowerKey = "suspend-then-hibernate";
          HandleLidSwitch = "suspend-then-hibernate";
          # Only suspend on lid closed when laptop is disconnected
          HandleLidSwitchDocked = lib.mkDefault "ignore";
          HandleLidSwitchExternalPower = lib.mkDefault "lock";
        };
      };

      # For battery status reporting
      upower.enable = true;

      power-profiles-daemon.enable = false;
      tlp = {
        enable = true;
        # Replacement for power-profiles-daemon
        pd.enable = true;
      };
    };
  };
}

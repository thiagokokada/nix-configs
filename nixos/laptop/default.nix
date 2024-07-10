{ config, lib, ... }:

{
  imports = [
    ./wireless.nix
    ./tlp.nix
  ];

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
      # Enable Blueman to manage Bluetooth
      blueman.enable = true;

      # For battery status reporting
      upower.enable = true;

      logind = {
        powerKey = "suspend-then-hibernate";
        lidSwitch = "suspend-then-hibernate";
        # Only suspend on lid closed when laptop is disconnected
        lidSwitchDocked = lib.mkDefault "ignore";
        lidSwitchExternalPower = lib.mkDefault "lock";
      };
    };
  };
}

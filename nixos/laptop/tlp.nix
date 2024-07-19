{ config, lib, ... }:

let
  cfg = config.nixos.laptop.tlp;
in
{
  options.nixos.laptop.tlp = {
    enable = lib.mkEnableOption "TLP config" // {
      default = config.nixos.laptop.enable;
    };
    # Use `tlp fullcharge` while connect though AC to charge it to 100% when
    # this option is set.
    batteryThreshold = {
      start = lib.mkOption {
        default = null;
        example = 75;
        type = with lib.types; nullOr int;
        description = "Start of battery charging threshold.";
      };
      stop = lib.mkOption {
        default = null;
        example = 80;
        type = with lib.types; nullOr int;
        description = "Stop of battery charging threshold.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # This will set CPU_SCALING_GOVERNOR_ON_{AC,BAT} options in TLP
    # 1200 is more priority than mkOptionDefault, less than mkDefault
    powerManagement.cpuFreqGovernor = lib.mkOverride 1200 "ondemand";

    # Reduce power consumption
    services.tlp = {
      enable = true;
      # https://linrunner.de/tlp/support/optimizing.html
      settings = {
        # Enable the platform profile low-power
        PLATFORM_PROFILE_ON_BAT = lib.mkDefault "balanced";
        # Enable the platform profile performance
        PLATFORM_PROFILE_ON_AC = lib.mkDefault "performance";
        # Enable runtime power management
        RUNTIME_PM_ON_AC = lib.mkDefault "auto";
        # Set battery thresholds
        START_CHARGE_THRESH_BAT0 = lib.mkIf (cfg.batteryThreshold.start != null) cfg.batteryThreshold.start;
        STOP_CHARGE_THRESH_BAT0 = lib.mkIf (cfg.batteryThreshold.stop != null) cfg.batteryThreshold.stop;
      };
    };
  };
}

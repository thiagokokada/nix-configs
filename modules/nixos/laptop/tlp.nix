{
  config,
  lib,
  libEx,
  ...
}:

let
  cfg = config.nixos.laptop.tlp;
in
{
  options.nixos.laptop.tlp = {
    enable = lib.mkEnableOption "TLP config" // {
      default = !config.services.power-profiles-daemon.enable && config.nixos.laptop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    # This will set CPU_SCALING_GOVERNOR_ON_{AC,BAT} options in TLP
    powerManagement.cpuFreqGovernor = libEx.mkLocalOptionDefault "ondemand";

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
      };
    };
  };
}

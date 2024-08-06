{ config, lib, ... }:

let
  cfg = config.nixos.system.vm;
in
{
  options.nixos.system.vm = {
    enable = lib.mkEnableOption "Virtual Machine config" // {
      default = config.nixos.system.enable;
    };
    vmConfig = lib.mkOption {
      type = lib.types.attrs;
      description = "Virtualisation options.";
      default = {
        memorySize = 4096;
        cores = 4;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      vmVariant = {
        virtualisation = cfg.vmConfig;
      };
      vmVariantWithBootLoader = {
        virtualisation = cfg.vmConfig;
      };
    };
  };
}

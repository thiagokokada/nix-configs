{ pkgs, lib, ... }:

with lib;
{
  options.device = {
    type = mkOption {
      type = types.enum [ "desktop" "notebook" ];
      description = "Type of device";
      default = "desktop";
    };
    netDevices = mkOption {
      type = with types; (listOf str);
      description = "Available net devices";
      example = [ "eno1" "wlp2s0" ];
      default = [ "eth0" ];
    };
    mountPoints = mkOption {
      type = with types; nullOr (listOf str);
      description = "Available mount points";
      example = [ "/" "/mnt/backup" ];
      default = null;
    };
  };
}

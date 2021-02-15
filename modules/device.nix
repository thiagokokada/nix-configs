{ pkgs, lib, ... }:

with lib;
{
  options.device = {
    type = mkOption {
      type = types.enum [ "desktop" "notebook" ];
      description = "Type of device";
      default = "desktop";
    };
    mountPoints = mkOption {
      type = with types; nullOr (listOf str);
      description = "Available mount points";
      example = [ "/" "/mnt/backup" ];
      default = null;
    };
  };
}

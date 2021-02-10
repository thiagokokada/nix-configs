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
      # TODO: extract this from hardware-configuration.nix when possible
      default = [ "/" ];
      example = [ "/" "/mnt/backup" ];
    };
  };
}

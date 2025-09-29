{ config, lib, ... }:
let
  cfg = config.nixos.system.networkd;
in
{
  options.nixos.system.networkd = {
    enable = lib.mkEnableOption "systemd-networkd config";
  };

  config = lib.mkIf cfg.enable {
    services.resolved = {
      enable = true;
      # Can make DNS lookups really slow
      dnssec = "false";
    };
    networking.useNetworkd = true;
  };
}

{ config, lib, ... }:
let
  cfg = config.nixos.server.networkd;
in
{
  options.nixos.server.networkd = {
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

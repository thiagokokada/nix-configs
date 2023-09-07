{ config, lib, ... }:
let
  cfg = config.nixos.server.networkd;
in
{
  options.nixos.server.networkd = {
    enable = lib.mkEnableOption "systemd-networkd config" // {
      default = config.nixos.server.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.network = {
      enable = true;
      networks."10-wan" = {
        matchConfig.Name = "en*";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          # accept Router Advertisements for Stateless IPv6 Autoconfiguraton (SLAAC)
          IPv6AcceptRA = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

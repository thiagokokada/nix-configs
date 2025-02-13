{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (config.meta) username;
  cfg = config.nixos.server.tailscale;
  serviceCfg = config.services.tailscale;
in
{
  options.nixos.server.tailscale = {
    enable = lib.mkEnableOption "Tailscale config (server side)";
    net.ifaces = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Net interfaces to enable transport layer offload.";
      default = config.device.net.ifaces;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ serviceCfg.interfaceName ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ serviceCfg.port ];
    };

    services = {
      networkd-dispatcher = lib.mkIf (cfg.net.ifaces != [ ]) {
        enable = config.networking.useNetworkd;
        # https://tailscale.com/kb/1320/performance-best-practices#linux-optimizations-for-subnet-routers-and-exit-nodes
        rules."enable-transport-layer-offload" = {
          onState = [ "routable" ];
          script = # bash
            ''
              #!${pkgs.runtimeShell}
              ${lib.concatStringsSep "\n" (
                builtins.map (
                  iface: # bash
                  ''
                    if [[ "$IFACE" == "${iface}" ]]; then
                      ${lib.getExe pkgs.ethtool} -K "${iface}" rx-udp-gro-forwarding on rx-gro-list off
                    fi
                  '') config.device.net.ifaces
              )}
            '';
        };
      };
      tailscale = {
        enable = true;
        permitCertUid = toString config.users.users.${username}.uid;
        useRoutingFeatures = lib.mkDefault "server";
        extraUpFlags = [
          "--advertise-exit-node"
          "--ssh"
        ];
      };
    };
  };
}

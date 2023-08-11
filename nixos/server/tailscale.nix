{ lib, config, pkgs, ... }:

let
  inherit (config.meta) username;
in
{
  options.nixos.server.tailscale.enable = lib.mkEnableOption "Tailscale config";

  config = lib.mkIf config.nixos.server.tailscale.enable {
    environment.systemPackages = with pkgs; [ tailscale ];

    services.tailscale = {
      enable = true;
      permitCertUid = toString config.users.users.${username}.uid;
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--advertise-exit-node"
        "--ssh"
      ];
    };

    networking.firewall = {
      # always allow traffic from your Tailscale network
      trustedInterfaces = [ "tailscale0" ];

      # allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}

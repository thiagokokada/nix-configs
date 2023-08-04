{ config, pkgs, ... }:

let
  inherit (config.meta) username;
in
{
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
}

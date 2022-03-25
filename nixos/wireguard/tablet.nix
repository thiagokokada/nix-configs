{ ... }:
{
  networking.wireguard.interfaces.wg0.peers = [{
    publicKey = "+fMp5IGX+b6ne9xM6+UaTv1OQggUfmbLCNDdycAi3xA=";
    allowedIPs = [ "10.100.0.3/32" ];
  }];
}

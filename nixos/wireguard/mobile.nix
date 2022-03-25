{ ... }:
{
  networking.wireguard.interfaces.wg0.peers = [{
    publicKey = "ZQzoQB1VFiTnpbCrBKk13gx6GHvoYFcGvF8p/Po7N2o=";
    allowedIPs = [ "10.100.0.2/32" ];
  }];
}

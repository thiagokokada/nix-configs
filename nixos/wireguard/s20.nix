{ ... }:
{
  networking.wireguard.interfaces.wg0.peers = [{
    publicKey = "AYUeTwwgm7JCKt0JHsrdD+3kIiXeQr84GME3aYTyCyE=";
    allowedIPs = [ "10.100.0.2/32" ];
  }];
}

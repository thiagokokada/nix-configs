{ config, lib, ... }:

let
  cfg = config.nixos.server.wireguard;
in
{
  # Generate with `wg-generate-config` script
  config = lib.mkIf (cfg.enable && cfg.externalUrl == "mirai-vps.duckdns.org") {
    networking.wireguard.interfaces.${cfg.wgInterface}.peers = [
      (import ./mitab5.nix)
      (import ./pixel6.nix)
      (import ./s20.nix)
      (import ./tabs8.nix)
    ];
  };
}

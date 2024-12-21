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
    services.resolved.enable = true;
    networking.useNetworkd = true;
  };
}

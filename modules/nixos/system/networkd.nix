{ config, lib, ... }:
let
  cfg = config.nixos.system.networkd;
in
{
  options.nixos.system.networkd = {
    enable = lib.mkEnableOption "systemd-networkd config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.resolved = {
      enable = true;
      settings.Resolve.DNSSEC = false;
    };
    networking.useNetworkd = true;
  };
}

{ config, lib, ... }:

{
  options.nixos.server.iperf3.enable = lib.mkEnableOption "IPerf3 config";

  config = lib.mkIf config.nixos.server.iperf3.enable {
    services.iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}

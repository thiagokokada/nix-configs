{ lib, config, ... }:
{
  options.nixos.server.enable = lib.mkEnableOption "server config" // {
    default = config.device.type == "server";
  };

  imports = [
    ./duckdns-updater.nix
    ./iperf3.nix
    ./plex.nix
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
    ./watchdogd.nix
  ];

  config = lib.mkIf config.nixos.server.enable {
    system.autoUpgrade = {
      allowReboot = lib.mkDefault true;
      rebootWindow = {
        lower = lib.mkDefault "02:30";
        upper = lib.mkDefault "05:30";
      };
      randomizedDelaySec = lib.mkDefault "30min";
    };
  };
}

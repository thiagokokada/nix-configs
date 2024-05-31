{ lib, config, ... }:
{
  options.nixos.server.enable = lib.mkEnableOption "server config" // {
    default = config.device.type == "server";
  };

  imports = [
    ./duckdns-updater.nix
    ./iperf3.nix
    ./jellyfin.nix
    ./networkd.nix
    ./plex.nix
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
    ./watchdogd.nix
  ];

  config = lib.mkIf config.nixos.server.enable {
    # Enable NixOS auto-upgrade
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:thiagokokada/nix-configs";
    };
  };
}

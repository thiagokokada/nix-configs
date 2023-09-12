{ lib, config, ... }:
{
  options.nixos.server.enable = lib.mkEnableOption "server config";

  imports = [
    ./duckdns-updater.nix
    ./networkd.nix
    ./plex.nix
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
    ./wireguard
  ];

  config = lib.mkIf config.nixos.server.enable {
    # Enable watchdog
    systemd.watchdog = {
      runtimeTime = "30s";
      rebootTime = "10m";
    };
    # Enable NixOS auto-upgrade
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:thiagokokada/nix-configs";
    };
  };
}

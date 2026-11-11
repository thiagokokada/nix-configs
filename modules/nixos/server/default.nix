{ ... }:
{
  imports = [
    ./duckdns-updater.nix
    ./iperf3.nix
    ./plex
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
    ./watchdogd.nix
  ];
}

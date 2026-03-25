{ ... }:
{
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
}

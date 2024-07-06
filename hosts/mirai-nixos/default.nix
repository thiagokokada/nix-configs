# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ flake, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nixos
    flake.inputs.disko.nixosModules.disko
  ];

  disko.devices = import ./disk-config.nix;

  device = {
    net.ifaces = [ "ens3" ];
    type = "server";
  };

  nixos = {
    server = {
      iperf3.enable = true;
      jellyfin.enable = true;
      plex.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        domain = "mirai-nixos.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs = {
          enable = true;
          useHttpServer = true;
        };
      };
    };
    system.smart.enable = false;
  };

  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";
    address = [
      "148.135.35.70/26"
      "148.135.35.71/26"
      "2607:f130:0:f3:ff:ff:d581:184c/64"
    ];
    dns = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    routes = [
      { routeConfig.Gateway = "148.135.35.65"; }
      { routeConfig.Gateway = "2607:f130:0:f3:0:0:0:1"; }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
}

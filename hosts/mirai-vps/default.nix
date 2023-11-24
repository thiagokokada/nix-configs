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

  device.type = "server";

  nixos = {
    server = {
      iperf3.enable = true;
      jellyfin.enable = true;
      plex.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        domain = "mirai-vps.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs = {
          enable = true;
          useHttpServer = true;
        };
      };
    };
    system.smart.enable = false;
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  networking.hostName = "mirai-vps";
}

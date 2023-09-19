# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos/home.nix
      ../../nixos/minimal.nix
      ../../nixos/server
    ];

  nixos.home.imports = [
    ../../home-manager/minimal.nix
  ];

  device.type = "server";

  nixos = {
    server = {
      enable = true;
      iperf3.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        domain = "zatsune-nixos.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs.enable = true;
      };
    };
    system.smart.enable = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zatsune-nixos";
}

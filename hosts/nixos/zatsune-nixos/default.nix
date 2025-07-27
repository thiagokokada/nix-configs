# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, flake, ... }@inputs:

let
  oci-common = import "${modulesPath}/virtualisation/oci-common.nix" {
    inherit (inputs) pkgs lib config;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    flake.inputs.disko.nixosModules.disko
  ]
  ++ oci-common.imports;

  boot = {
    inherit (oci-common.boot) kernelParams;
  };

  disko.devices = import ./disk-config.nix;

  device = {
    net.ifaces = [ "enp0s6" ];
    type = "server";
  };

  nixos = {
    # Has tons of memory and slow disk
    nix.tmpOnDisk = false;
    desktop.wayland.enable = true;
    system.virtualisation.enable = false;
    server = {
      iperf3.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        ipv6.enable = true;
        domain = "zatsune-nixos.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs = {
          enable = true;
          useHttpServer = true;
        };
      };
    };
    system.smart.enable = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    inherit (oci-common.networking) timeServers;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}

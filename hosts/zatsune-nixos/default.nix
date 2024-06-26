# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, flake, config, lib, pkgs, ... }:

let
  oci-common = import "${modulesPath}/virtualisation/oci-common.nix" { inherit config lib pkgs; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nixos
    flake.inputs.disko.nixosModules.disko
  ] ++ oci-common.imports;

  boot = { inherit (oci-common.boot) kernelParams; };

  disko.devices = import ./disk-config.nix;

  device.type = "server";

  nixos = {
    dev.enable = true;
    # Has tons of memory and slow disk
    nix.tmpOnDisk = false;
    desktop.wayland.enable = true;
    server = {
      iperf3.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        ipv6 = {
          enable = true;
          device = "enp0s6";
        };
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
    hostName = "zatsune-nixos";
  };
}

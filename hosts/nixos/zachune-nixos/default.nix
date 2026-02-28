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
    net.ifaces = [ "ens3" ];
    type = "server";
  };

  nixos = {
    server = {
      iperf3.enable = true;
      ssh = {
        enable = true;
        root.enableLogin = true;
      };
      tailscale.enable = true;
      watchdogd.enable = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    inherit (oci-common.networking) timeServers;
  };

  time.timeZone = "Europe/Dublin";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, flake, ... }@inputs:

let
  oci-common = import "${modulesPath}/virtualisation/oci-common.nix" { inherit (inputs) pkgs lib config; };
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
    server = {
      iperf3.enable = true;
      ssh = {
        enable = true;
        root.enableLogin = true;
      };
      tailscale.enable = true;
    };
    system.smart.enable = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = { inherit (oci-common.networking) timeServers; };

  time.timeZone = "Europe/Dublin";
}

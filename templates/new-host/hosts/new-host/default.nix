# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    # Use `nixos-generate-config` to generate `hardware-configuration.nix` file
    ./hardware-configuration.nix
    ../../nixos
    # inputs.hardware.nixosModules.common-cpu-intel
  ];

  device = {
    type = "laptop";
    netDevices = [ "enp3s0" "wlan0" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "<hostname>";
}

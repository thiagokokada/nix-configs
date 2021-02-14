# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "miku-nixos"; # Define your hostname.

  boot.initrd = {
    luks.devices."root" = {
      device = "/dev/disk/by-uuid/02e41fb9-1611-461f-ba7c-4e44d828cf8d";
      preLVM = true;
      allowDiscards = true;
    };
  };
}


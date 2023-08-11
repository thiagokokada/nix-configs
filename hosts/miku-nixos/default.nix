# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, ... }:

let
  inherit (flake) inputs;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/cross-compiling.nix
    ../../nixos/games.nix
    ../../nixos/pc.nix
    ../../nixos/security.nix
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  nixos.server = {
    plex.enable = true;
    rtorrent.enable = true;
    samba.enable = true;
    ssh.enable = true;
  };

  device = {
    type = "desktop";
    netDevices = [ "eno1" ];
    mediaDir = "/mnt/archive/${config.meta.username}";
  };

  # Fix quirk in Renesas USB hub
  boot.kernelParams = [ "pci=noaer" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel 5.10.x got stucked at boot on screen:
  # "EFI stub: loaded initrd from command line"
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  boot.initrd.luks.devices = {
    "enc-windows".device =
      "/dev/disk/by-uuid/4c14148f-87b3-4bfe-a65b-062681574241";
    "root" = {
      device = "/dev/disk/by-uuid/02e41fb9-1611-461f-ba7c-4e44d828cf8d";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "miku-nixos";
}

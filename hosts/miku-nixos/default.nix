# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/cli.nix
    ../../nixos/desktop.nix
    ../../nixos/dev.nix
    ../../nixos/fonts.nix
    ../../nixos/game.nix
    ../../nixos/home.nix
    ../../nixos/locale.nix
    ../../nixos/misc.nix
    ../../nixos/pc.nix
    ../../nixos/security.nix
    ../../nixos/system.nix
    ../../nixos/xserver.nix
    ../../cachix.nix
    ../../modules/device.nix
    ../../modules/my.nix
    ../../overlays
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  device = {
    type = "desktop";
    netDevices = [ "eno1" ];
  };

  # Fix quirk in Renesas USB hub
  boot.kernelParams = [ "pci=noaer" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    "enc-win10".device =
      "/dev/disk/by-uuid/4c14148f-87b3-4bfe-a65b-062681574241";
    "root" = {
      device = "/dev/disk/by-uuid/02e41fb9-1611-461f-ba7c-4e44d828cf8d";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "miku-nixos";
}

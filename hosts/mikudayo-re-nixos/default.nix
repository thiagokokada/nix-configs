# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, ... }:

let
  inherit (self) inputs;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/cross-compiling.nix
    ../../nixos/games.nix
    ../../nixos/laptop.nix
    ../../cachix.nix
    ../../modules
    ../../overlays
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  device = {
    type = "notebook";
    netDevices = [ "enp3s0" "wlan0" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e977b087-34e0-46d7-88f1-e978f6be4b67";
      preLVM = true;
      allowDiscards = true;
    };
  };

  time.timeZone = "Europe/Dublin";

  networking.hostName = "mikudayo-re-nixos";
}

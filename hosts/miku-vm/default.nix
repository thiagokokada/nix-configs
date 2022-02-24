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
    ../../cachix.nix
    ../../modules
    ../../overlays
  ];

  device = {
    type = "vm";
    netDevices = [ "eno1" ];
  };

  hardware.video.hidpi.enable = true;

  theme.fonts.dpi = 320;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "miku-vm";
}

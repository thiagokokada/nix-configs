# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, self, lib, ... }:

let
  inherit (self) inputs;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
    ../../nixos/cross-compiling.nix
    ../../nixos/games.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  device = {
    type = "laptop";
    netDevices = [ "enp3s0" "wlan0" ];
  };

  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e977b087-34e0-46d7-88f1-e978f6be4b67";
      preLVM = true;
      allowDiscards = true;
    };
  };

  time = {
    # For Windows interop
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Dublin";
  };

  # Backport the latest kernel for fixes
  # And the latest NVIDIA drivers, to allow building with newer kernels
  nixpkgs.overlays = [
    (final: prev: {
      inherit (final.unstable) linuxPackages_latest nvidia_x11;
    })
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Memory is kinda low to build some packages, really :P
  boot.tmpOnTmpfs = false;

  networking.hostName = "mikudayo-re-nixos";

  services.tlp = {
    settings = {
      # After long sleep the audio device disappears
      # POWER_SAVE is on AC by default
      SOUND_POWER_SAVE_ON_AC = 0;
    };
  };
}

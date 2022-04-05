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
    ../../nixos/laptop.nix
    ../../cachix.nix
    ../../modules
    ../../overlays
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  device = {
    type = "notebook";
    netDevices = [ "enp3s0" "wlan0" ];
  };

  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
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

  time = {
    # For Windows interop
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Dublin";
  };

  # Newest LTS, fixes some issues
  boot.kernelPackages = pkgs.linuxPackages_5_15;
  # Add support for intel_pstate/intel_cpufreq driver
  boot.kernelPatches = [{
    name = "add_tigerlake_to_intel_pstate";
    patch = ./add_tigerlake_to_intel_pstate.diff;
  }];

  boot.tmpOnTmpfs = false;
  powerManagement.cpuFreqGovernor = "schedutil";

  networking.hostName = "mikudayo-re-nixos";
}

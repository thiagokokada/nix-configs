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

  networking.hostName = "mikudayo-re-nixos";
}

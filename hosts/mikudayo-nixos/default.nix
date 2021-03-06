# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/cli.nix
    ../../nixos/desktop.nix
    ../../nixos/dev.nix
    ../../nixos/fonts.nix
    ../../nixos/game.nix
    ../../nixos/home.nix
    ../../nixos/laptop.nix
    ../../nixos/locale.nix
    ../../nixos/misc.nix
    ../../nixos/system.nix
    ../../nixos/user.nix
    ../../nixos/xserver.nix
    ../../cachix.nix
    ../../modules/device.nix
    ../../modules/my.nix
    ../../overlays
    inputs.hardware.nixosModules.common-gpu-nvidia
    # inputs.hardware.nixosModules.common-gpu-nvidia-disable
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  device = {
    type = "notebook";
    netDevices = [ "enp3s0" "wlan0" ];
    mountPoints = [ "/" ];
  };

  hardware.nvidia.prime = {
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ "pci=noaer" ];

  networking.hostName = "mikudayo-nixos";

  services.xserver = {
    layout = "br,us";
    xkbVariant = "abnt2,intl";
  };
}

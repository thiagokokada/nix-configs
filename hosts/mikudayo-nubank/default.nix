# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let inherit (config.my) username;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/cli.nix
    ../../nixos/desktop.nix
    ../../nixos/dev.nix
    ../../nixos/fonts.nix
    ../../nixos/home.nix
    ../../nixos/laptop.nix
    ../../nixos/locale.nix
    ../../nixos/misc.nix
    ../../nixos/system.nix
    ../../nixos/user.nix
    ../../nixos/xserver.nix
    ../../nixos/yubikey.nix
    ../../cachix.nix
    ../../modules/device.nix
    ../../modules/my.nix
    ../../overlays
    # inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-gpu-nvidia-disable
    inputs.hardware.nixosModules.common-cpu-intel
  ];

  device = {
    type = "notebook";
    netDevices = [ "enp56s0u2u2" "wlan0" ];
  };

  hardware.nvidia.prime = {
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  home-manager.users.${username}.imports = [ ../../home-manager/nubank.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    enc-pv = {
      device = "/dev/disk/by-uuid/c7b7b6ed-a413-47f8-91fe-8d5260c91faf";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "mikudayo-nubank";
}

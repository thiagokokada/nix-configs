# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, lib, ... }:

let
  inherit (flake) inputs;
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

  hardware.nvidia = {
    modesetting.enable = true;
    # Enable experimental NVIDIA power management via systemd
    powerManagement.enable = true;
    prime = {
      offload.enable = false;
      sync.enable = true;

      # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
      intelBusId = "PCI:0:2:0";

      # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
      nvidiaBusId = "PCI:1:0:0";
    };
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

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  networking.hostName = "mikudayo-re-nixos";

  # I think the usage of NVIDIA drivers is making lidSwitchDocked not working correctly
  services.logind.lidSwitchExternalPower = "ignore";
  # The audio device from this notebook doesn't seem to like short buffers too much
  services.pipewire.lowLatency.quantum = 128;

  # Use ultrawide wallpaper
  home-manager.users.${config.meta.username}.theme.wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;

  # This allows you to dynamically switch between NVIDIA<->Intel using
  # nvidia-offload script
  specialisation = {
    nvidia-offload.configuration = {
      hardware.nvidia = {
        prime = {
          offload.enable = lib.mkForce true;
          sync.enable = lib.mkForce false;
        };
        modesetting.enable = lib.mkForce false;
      };
      system.nixos.tags = [ "nvidia-offload" ];
    };
  };
}

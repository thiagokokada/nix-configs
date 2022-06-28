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

  hardware.nvidia = {
    # Enable experimental NVIDIA power management via systemd
    powerManagement.enable = true;
    prime = {
      offload.enable = true;

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

  # Configure hibernation
  boot.resumeDevice = (builtins.head config.swapDevices).device;

  time = {
    # For Windows interop
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Dublin";
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod;
  networking.hostName = "mikudayo-re-nixos";

  # Reinit audio after suspend, since sometimes the audio devices "disappears"
  systemd.services.reinit-audio-after-suspend = rec {
    description = "Reinit audio after suspend";
    serviceConfig = {
      ExecStart = "-${pkgs.alsa-utils}/bin/alsactl init";
      Type = "simple";
    };
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-than-hibernate.target" ];
    unitConfig = {
      After = wantedBy;
    };
  };

  # https://nixos.wiki/wiki/Nvidia#booting_with_an_external_display
  specialisation = {
    external-display.configuration = {
      system.nixos.tags = [ "external-display" ];
      hardware.nvidia = {
        prime = {
          offload.enable = lib.mkForce false;
          sync.enable = true;
        };
        modesetting.enable = true;
        powerManagement.enable = lib.mkForce false;
      };
    };
  };
}

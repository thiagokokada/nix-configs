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
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
  ];

  device = {
    type = "desktop";
    netDevices = [ "enp2s0f1" ];
  };

  nixos.server = {
    tailscale.enable = true;
    ssh.enable = true;
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hachune-nixos";

  # Use ultrawide wallpaper
  home-manager.users.${config.meta.username}.theme.wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;

  # Reduce power consumption
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };

  # Used for firmware updates
  services.fwupd.enable = true;

  time.timeZone = "Europe/Dublin";
}

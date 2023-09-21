# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake, ... }:

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
    mediaDir = "/mnt/media/${config.meta.username}";
  };

  nixos = {
    desktop.enable = true;
    laptop.tlp = {
      enable = true;
      cpuFreqGovernor = "schedutil";
    };
    server = {
      enable = true;
      iperf3.enable = true;
      jellyfin.enable = true;
      networkd.enable = true;
      plex.enable = true;
      rtorrent.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        certs.enable = true;
        domain = "hachune-nixos.duckdns.org";
      };
    };
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hachune-nixos";

  # Use ultrawide wallpaper
  home-manager.users.${config.meta.username}.theme.wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;

  # Reduce power consumption
  time.timeZone = "America/Sao_Paulo";
}

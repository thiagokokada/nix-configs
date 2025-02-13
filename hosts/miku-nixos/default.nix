# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  flake,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    flake.inputs.hardware.nixosModules.common-cpu-intel
    flake.outputs.nixosModules.default
  ];

  nixos = {
    dev.enable = true;
    games.enable = true;
    server = {
      plex.enable = true;
      rtorrent.enable = true;
      samba.enable = true;
      ssh.enable = true;
    };
  };

  device = {
    type = "desktop";
    net.ifaces = [ "eno1" ];
    media.directory = "/mnt/archive/${config.meta.username}";
  };

  # Fix quirk in Renesas USB hub
  boot.kernelParams = [ "pci=noaer" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel 5.10.x got stucked at boot on screen:
  # "EFI stub: loaded initrd from command line"
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  boot.initrd.luks.devices = {
    "enc-windows".device = "/dev/disk/by-uuid/4c14148f-87b3-4bfe-a65b-062681574241";
    "root" = {
      device = "/dev/disk/by-uuid/02e41fb9-1611-461f-ba7c-4e44d828cf8d";
      preLVM = true;
      allowDiscards = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}

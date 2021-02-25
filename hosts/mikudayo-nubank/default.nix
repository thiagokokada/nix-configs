# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let inherit (config.my) username;
in {
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
    ../../nixos/yubikey.nix
    # ../../nixos/optimus.nix
    ../../nixos/optimus-disable.nix
    ../../nixos/system.nix
    ../../nixos/xserver.nix
    ../../cachix.nix
    ../../modules/device.nix
    ../../modules/my.nix
    ../../overlays
  ];

  device = {
    type = "notebook";
    netDevices = [ "enp62s0u1u2" "wlan0" ];
  };

  home-manager.users.${username}.imports = [ ../../home-manager/nubank.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    enc-pv = {
      device = "/dev/disk/by-uuid/c7002ec7-b9a9-47a1-858a-a8ec3d18c343";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "mikudayo-nubank";
}

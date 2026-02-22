# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  lib,
  flake,
  ...
}:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    flake.inputs.disko.nixosModules.disko
    flake.inputs.hardware.nixosModules.common-cpu-amd
    flake.inputs.hardware.nixosModules.common-gpu-amd
  ];

  device = {
    type = "steam-machine";
    net.ifaces = [
      "enp8s0"
      "wlp7s0"
    ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
      };
    };
  };

  fonts.fontconfig.subpixel.rgba = "rgb";

  nixos = {
    games = {
      enable = true;
      rocksmith.enable = true;
    };
    home.restoreBackups = true;
    server = {
      plex.enable = true;
      rtorrent = {
        enable = true;
        ratio.enable = true;
      };
      ssh.enable = true;
    };
    system = {
      gpu.maker = "amd";
      binfmt = {
        enable = true;
        windows.enable = true;
      };
    };
  };

  time.timeZone = "Europe/Dublin";

  services = {
    # Used for firmware updates
    fwupd.enable = true;
    ollama.loadModels = [
      "deepseek-r1:14b"
    ];
  };

  specialisation.window-manager-mode.configuration = {
    boot.loader.systemd-boot.sortKey = "s_nixos";
    device.type = lib.mkForce "desktop";
    system.nixos.tags = [ "with-window-manager" ];
  };

  networking.networkmanager = {
    connectionConfig = {
      # Disable powersave for Wi-Fi to see if this improves reliability
      "wifi.powersave" = 2;
    };
    # iwd doesn't allow for pinning a specific BSSID (i.e., router by MAC),
    # but since mt7925e is kinda buggy right now we need this support to
    # pin 2.4GHz, so go back to wpa_supplicant
    wifi.backend = "wpa_supplicant";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?
}

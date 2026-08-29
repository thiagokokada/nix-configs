# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, flake, ... }:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    flake.inputs.disko.nixosModules.disko
    flake.inputs.hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  device.type = "laptop";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = [ "xe" ];
    loader = {
      efi.canTouchEfiVariables = true;
      limine = {
        enable = true;
        secureBoot.enable = true;
        style.interface.resolution = "2880x1920";
      };
    };
  };

  nixos = {
    dev.platformio.enable = true;
    desktop.gnome.enable = true;
    window-manager.enable = false;
    games.steam.enable = true;
    server = {
      ssh.enable = true;
      tailscale.enable = true;
    };
    system.gpu.maker = "intel";
  };

  services = {
    # For fingerprint scanner
    fprintd.enable = true;
  };

  # https://nwildner.com/posts/2024-06-05-dell-laptop-suspend/
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
    SuspendState = "freeze";
  };

  time.timeZone = "Europe/Dublin";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "26.11"; # Did you read the comment?
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ flake, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nixos
    flake.inputs.disko.nixosModules.disko
  ];

  nixos.home.imports = [
    ../../home-manager/minimal.nix
  ];

  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    "console=ttyAMA0,115200"
  ];

  disko.devices = import ./disk-config.nix;

  device.type = "server";

  nixos = {
    server = {
      iperf3.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        ipv6 = {
          enable = true;
          device = "enp0s6";
        };
        domain = "zatsune-nixos.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs.enable = true;
      };
    };
    system.smart.enable = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zatsune-nixos";
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../nixos
    ];

  device.type = "server";

  nixos = {
    server = {
      iperf3.enable = true;
      jellyfin.enable = true;
      plex.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      duckdns-updater = {
        enable = true;
        domain = "mirai-vps.duckdns.org";
        onCalendar = "daily"; # fixed IP, mostly for health checking
        certs = {
          enable = true;
          useHttpServer = true;
        };
      };
    };
    system.smart.enable = false;
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "mirai-vps";
}

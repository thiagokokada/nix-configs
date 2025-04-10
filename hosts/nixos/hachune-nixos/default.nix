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
    flake.inputs.hardware.nixosModules.common-cpu-amd
    flake.inputs.hardware.nixosModules.common-gpu-amd
  ];

  device = {
    type = "desktop";
    net.ifaces = [ "enp2s0f1" ];
    media.directory = "/mnt/media/${config.meta.username}";
  };

  nixos = {
    laptop.tlp.enable = true;
    system.virtualisation.enable = false;
    server = {
      enable = true;
      iperf3.enable = true;
      networkd.enable = true;
      plex.enable = true;
      rtorrent.enable = true;
      samba.enable = true;
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

  # Use ultrawide wallpaper
  home-manager.users.${config.meta.username}.home-manager.desktop.theme.wallpaper.path =
    pkgs.wallpapers.hatsune-miku_stylized-ultrawide;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}

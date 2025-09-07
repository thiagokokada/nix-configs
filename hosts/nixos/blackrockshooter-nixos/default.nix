# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  flake,
  ...
}:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    flake.inputs.disko.nixosModules.disko
  ];

  device = {
    type = "desktop";
    net.ifaces = [
      "enp8s0"
      "wlp7s0"
    ];
  };

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  theme = {
    fonts.dpi = 150;
    wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;
  };

  nixos = {
    games = {
      enable = true;
      gpu = "amd";
    };
    server = {
      ssh.enable = true;
      tailscale.enable = true;
    };
    system = {
      binfmt.enable = true;
    };
  };

  programs.steam.gamescopeSession.args = [
    "-w 1600"
    "-h 900"
  ];

  time.timeZone = "Europe/Dublin";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?
}

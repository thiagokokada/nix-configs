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
    # https://bbs.archlinux.org/viewtopic.php?id=306366
    kernelParams = [ "mt7925e.disable_aspm=1" ];
    kernelPackages = pkgs.linuxPackages_cachyos;
    # Use the systemd-boot EFI boot loader
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  theme = {
    fonts.dpi = 150;
    wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;
  };

  nixos = {
    games = {
      enable = true;
    };
    server = {
      ssh.enable = true;
      tailscale.enable = true;
    };
    system = {
      gpu = "amd";
      binfmt.enable = true;
    };
  };

  time.timeZone = "Europe/Dublin";

  services.ollama.loadModels = [
    "deepseek-r1:14b"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "25.05"; # Did you read the comment?
}

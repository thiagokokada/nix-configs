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
    ./disk-config.nix
    ./hardware-configuration.nix
    flake.inputs.disko.nixosModules.disko
    flake.inputs.hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
    flake.outputs.nixosModules.default
  ];

  device = {
    type = "laptop";
    net.ifaces = [
      "enp2s0f0"
      "enp5s0"
      "wlan0"
    ];
    # This system is using btrfs subvolumes, so there is only root
    mount.points = [ "/" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_lqx;

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  home-manager.users.${config.meta.username} = {
    home-manager.desktop.theme = {
      fonts.dpi = 175;
      wallpaper.path = pkgs.wallpapers.hatsune-miku_stylized-ultrawide;
    };
  };

  nixos = {
    dev.enable = true;
    games = {
      enable = true;
      gpu = "amd";
    };
    laptop.tlp.batteryThreshold = {
      start = 75;
      stop = 80;
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

  # Used for firmware updates
  services.fwupd.enable = true;

  # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/1849
  systemd.services.fix-mic-light = {
    description = "Disables mic light (turned on by default)";
    script = ''
      echo 0 > /sys/class/leds/platform\:\:micmute/brightness
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ]; # starts after login
  };

  time.timeZone = "Europe/Dublin";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}

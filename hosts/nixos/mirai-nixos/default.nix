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
    flake.inputs.hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  device.type = "laptop";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "xe" ];

  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = true;
  boot.loader.limine.secureBoot.autoEnrollKeys.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixos = {
    desktop.kde.enable = true;
    window-manager.enable = false;
    games.steam.enable = true;
    server = {
      ssh.enable = true;
      tailscale.enable = true;
    };
  };

  services = {
    # For fingerprint scanner
    fprintd.enable = true;
    logind.settings.Login = {
      HibernateDelaySec = "2h";
    };
    displayManager = {
      autoLogin = {
        enable = true;
        user = config.nixos.home.username;
      };
    };
  };

  # Stops SDDM from prompting for fingerprint
  security.pam.services.login.fprintAuth = false;
  # https://nwildner.com/posts/2024-06-05-dell-laptop-suspend/
  systemd.sleep.settings.Sleep = {
    SuspendState = "freeze";
  };

  time.timeZone = "Europe/Dublin";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "26.11"; # Did you read the comment?
}

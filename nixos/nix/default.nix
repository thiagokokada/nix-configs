{ config, lib, pkgs, flake, ... }:

let
  cfg = config.nixos.nix;
in
{
  imports = [
    ./cross-compiling.nix
  ];

  options.nixos.nix = {
    enable = lib.mkDefaultOption "nix/nixpkgs config";
    tmpOnDisk = lib.mkDefaultOption "set nix's TMPDIR to /var/tmp (disk instead tmpfs)" // {
      enable = config.boot.tmp.useTmpfs;
    };
  };

  config = lib.mkIf cfg.enable {
    # Add some Nix related packages
    environment.systemPackages = with pkgs; [
      nixos-cleanup
      nom-rebuild
    ];

    nix = lib.mkMerge [
      (import ../../shared/nix.nix { inherit pkgs flake; })
      {
        gc = {
          automatic = true;
          persistent = true;
          randomizedDelaySec = "15m";
          dates = "3:15";
          options = "--delete-older-than 7d";
        };
        # Reduce disk usage
        daemonIOSchedClass = "idle";
        # Leave nix builds as a background task
        daemonCPUSchedPolicy = "idle";
      }
      {
        settings = {
          # For some reason when nix is running as daemon,
          # extra-{substituters,trusted-public-keys} doesn't work
          substituters = [ "https://cache.nixos.org/" ] ++ flake.outputs.nixConfig.extra-substituters;
          trusted-public-keys = flake.outputs.nixConfig.extra-trusted-public-keys;
        };
      }
    ];

    # Enable unfree packages
    nixpkgs.config.allowUnfree = true;

    # Change build dir to /var/tmp
    systemd.services.nix-daemon = {
      environment.TMPDIR = lib.mkIf cfg.tmpOnDisk "/var/tmp";
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = lib.mkDefault "23.11"; # Did you read the comment?
  };
}

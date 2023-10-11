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

    nix = {
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

      # Set the $NIX_PATH entry for nixpkgs. This is necessary in
      # this setup with flakes, otherwise commands like `nix-shell
      # -p pkgs.htop` will keep using an old version of nixpkgs
      nixPath = [
        "nixpkgs=${flake}"
      ];
      # Same as above, but for `nix shell nixpkgs#htop`
      registry.nixpkgs.flake = flake;

      settings =
        let
          substituters = import ../../shared/substituters.nix;
        in
        lib.mkMerge [
          (import ../../shared/nix-conf.nix)
          {
            # For some reason when nix is running as daemon,
            # extra-{substituters,trusted-public-keys} doesn't work
            substituters = substituters.extra-substituters;
            trusted-public-keys = substituters.extra-trusted-public-keys;
          }
        ];
    };

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

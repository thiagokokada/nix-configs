{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.nixos.nix;
in
{
  imports = [
    ./diff.nix
    ./remote-builders.nix
  ];

  options.nixos.nix = {
    enable = lib.mkEnableOption "nix/nixpkgs config" // {
      default = true;
    };
    tmpOnDisk = lib.mkEnableOption "set nix's TMPDIR to /var/tmp (disk instead tmpfs)" // {
      default = config.boot.tmp.useTmpfs;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # Add some Nix related packages
      systemPackages = with pkgs; [ nixos-cleanup ];
    };

    nix = {
      gc = {
        automatic = true;
        persistent = true;
        randomizedDelaySec = "15m";
        dates = "3:15";
        options = "--delete-older-than 7d";
      };
      # Optimise nix-store via service
      optimise.automatic = true;
      # Reduce disk usage
      daemonIOSchedClass = "best-effort";
      daemonIOSchedPriority = 7;
      # Leave nix builds as a background task
      daemonCPUSchedPolicy = "batch";

      # Customized nixpkgs, e.g.: `nix shell nixpkgs_#snes9x`
      registry.nixpkgs_.flake = flake;

      settings =
        let
          substituters = import ../../shared/substituters.nix;
        in
        lib.mkMerge [
          (import ../../shared/nix-conf.nix)
          {
            trusted-users = [
              "root"
              "@wheel"
            ];
            auto-optimise-store = true;
            max-jobs = "auto";
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
  };
}

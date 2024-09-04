{
  config,
  lib,
  flake,
  ...
}:

let
  cfg = config.nix-darwin.nix;
in
{
  imports = [ ./linux-builder.nix ];

  options.nix-darwin.nix.enable = lib.mkEnableOption "nix/nixpkgs config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    nix = {
      useDaemon = true;

      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

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
              "@admin"
            ];
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
  };
}

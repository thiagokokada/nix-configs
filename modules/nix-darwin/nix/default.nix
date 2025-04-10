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
      gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      # Customized nixpkgs, e.g.: `nix shell nixpkgs_#snes9x`
      registry.nixpkgs_.flake = flake;

      settings = lib.mkMerge [
        flake.outputs.configs.nix
        {
          trusted-users = [
            "root"
            "@admin"
          ];
        }
      ];
    };

    nixpkgs = {
      config = flake.outputs.configs.nixpkgs;
      overlays = [ flake.outputs.overlays.default ];
    };
  };
}

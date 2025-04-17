{
  config,
  lib,
  libEx,
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
        # Needs to use substituters/trusted-public-keys otherwise it doesn't
        # work in nix-daemon
        (libEx.translateKeys {
          "extra-substituters" = "substituters";
          "extra-trusted-public-keys" = "trusted-public-keys";
        } flake.outputs.internal.configs.nix)
        {
          trusted-users = [
            "root"
            "@admin"
          ];
        }
      ];
    };

    nixpkgs = {
      config = flake.outputs.internal.configs.nixpkgs;
      overlays = [ flake.outputs.overlays.default ];
    };
  };
}

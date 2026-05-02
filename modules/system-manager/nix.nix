{
  config,
  lib,
  libEx,
  flake,
  ...
}:

let
  cfg = config.system-manager.nix;
in
{
  options.system-manager.nix.enable = lib.mkEnableOption "Nix config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    nix = {
      enable = true;

      settings = lib.mkMerge [
        (libEx.translateKeys {
          "extra-substituters" = "substituters";
          "extra-trusted-public-keys" = "trusted-public-keys";
        } flake.outputs.internal.configs.nix)
        {
          trusted-users = [
            "root"
            "@wheel"
            "@sudo"
          ];
          auto-optimise-store = true;
        }
      ];
    };

    nixpkgs = {
      config = flake.outputs.internal.configs.nixpkgs;
    };
  };
}

{
  flake,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ flake.inputs.nix-index-database.homeModules.nix-index ];

  options.home-manager.cli.nixpkgs.enable = lib.mkEnableOption "nixpkgs tools config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.nixpkgs.enable {
    programs = {
      nix-index = {
        enable = true;
        symlinkToCacheHome = true;
      };
      nix-index-database.comma.enable = true;
    };

    home.packages =
      with pkgs;
      [
        nix-output-monitor
        (nixpkgs-review.override {
          withNom = true;
          withSandboxSupport = pkgs.stdenv.isLinux;
        })
      ]
      ++ lib.optionals stdenv.isLinux [
        nix-alien
      ];
  };
}

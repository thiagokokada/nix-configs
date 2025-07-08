{
  flake,
  config,
  pkgs,
  lib,
  ...
}:

let
  nixpkgs-review =
    if pkgs.stdenv.isLinux then
      pkgs.nixpkgs-review.override {
        withSandboxSupport = true;
        withNom = true;
      }
    else
      pkgs.nixpkgs-review.override { withNom = true; };
in
{
  imports = [ flake.inputs.nix-index-database.hmModules.nix-index ];

  options.home-manager.cli.nixpkgs.enable = lib.mkEnableOption "nixpkgs tools config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.nixpkgs.enable {
    programs = {
      nix-index = {
        enable = true;
        symlinkToCacheHome = true;
      };
      # Until https://github.com/nix-community/comma/pull/101 and a new release
      # is made
      # nix-index-database.comma.enable = true;
    };

    home.packages =
      with pkgs;
      [
        # https://github.com/nix-community/comma/pull/101
        flake.inputs.comma.packages.${pkgs.system}.comma
        nix-output-monitor
        nixpkgs-review
      ]
      ++ lib.optionals stdenv.isLinux [ flake.inputs.nix-alien.packages.${pkgs.system}.nix-alien ];
  };
}

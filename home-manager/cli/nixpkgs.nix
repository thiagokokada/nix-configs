{ flake, config, pkgs, lib, ... }:


let
  nixpkgs-review =
    if pkgs.stdenv.isLinux then
      pkgs.nixpkgs-review.override { withSandboxSupport = true; withNom = true; }
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
      nix-index-database.comma.enable = true;
    };

    home.packages = with pkgs; [
      nix-output-monitor
      nixpkgs-review
    ] ++ lib.optionals stdenv.isLinux [
      flake.inputs.nix-alien.packages.${pkgs.system}.nix-alien
    ];
  };
}

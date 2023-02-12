{ flake, pkgs, lib, system, ... }:

{
  imports = [ flake.inputs.nix-index-database.hmModules.nix-index ];
  home.packages = lib.optionals pkgs.stdenv.isLinux [ flake.inputs.nix-alien.packages.${system}.nix-alien ];
}

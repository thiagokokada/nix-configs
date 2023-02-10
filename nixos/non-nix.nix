{ pkgs, flake, system, ... }:

let
  inherit (flake.inputs.nix-alien.packages.${system}) nix-alien;
  inherit (flake.inputs.nix-index-database.packages.${system}) nix-index-with-db;
in
{
  environment.systemPackages = [
    nix-alien
    nix-index-with-db
  ];
}

{ pkgs, flake, system, ... }:

let
  inherit (flake.inputs.nix-alien.packages.${system}) nix-alien nix-index-update;
in
{
  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

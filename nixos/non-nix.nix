{ pkgs, flake, system, ... }:

{
  nixpkgs.overlays = [
    flake.inputs.nix-alien.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

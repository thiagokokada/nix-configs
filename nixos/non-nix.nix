{ pkgs, flake, system, ... }:

{
  nixpkgs.overlays = [
    flake.inputs.nix-alien.overlay
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

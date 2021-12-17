{ pkgs, self, system, ... }:

{
  nixpkgs.overlays = [
    self.inputs.nix-alien.overlay
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

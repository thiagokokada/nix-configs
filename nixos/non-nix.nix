{ pkgs, self, system, ... }:

{
  imports = [
    self.inputs.nix-ld.nixosModules.nix-ld
  ];

  nixpkgs.overlays = [
    self.inputs.nix-alien.overlay
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

{ pkgs, self, system, ... }:

{
  imports = [
    self.inputs.nix-ld.nixosModules.nix-ld
  ];

  nixpkgs.overlays = [
    (final: prev: {
      inherit (self.inputs.nix-alien.packages.${system}) nix-alien nix-index-update;
    })
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

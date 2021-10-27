{ pkgs, self, system, ... }:

{
  imports = [
    self.inputs.nix-ld.nixosModules.nix-ld
  ];

  environment.systemPackages = with pkgs; [
    nix-alien
    nix-index
    nix-index-update
  ];
}

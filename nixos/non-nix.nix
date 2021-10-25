{ pkgs, self, system, ... }:

{
  imports = [
    self.inputs.nix-ld.nixosModules.nix-ld
  ];

  environment.systemPackages = with pkgs; [
    nix-autobahn
    nix-index
  ];
}

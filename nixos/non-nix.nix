{ pkgs, self, system, ... }:

{
  imports = [
    self.inputs.nix-ld.nixosModules.nix-ld
  ];

  environment = {
    sessionVariables = {
      NIX_CC = "${pkgs.stdenv.cc}";
    };
    systemPackages = with pkgs; [
      nix-autobahn
      nix-index
    ];
  };
}

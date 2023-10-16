{ config, pkgs, lib, ... }:

{
  options.home-manager.dev.nix.enable = lib.mkEnableOption "Nix config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.nix.enable {
    home.packages = with pkgs; [
      nil
      nix-hash-fetchurl
      nix-hash-fetchzip
      nix-update
      nixpkgs-fmt
      statix
    ];
  };
}

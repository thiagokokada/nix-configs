{ config, lib, pkgs, ... }:

{
  nixpkgs.config = import ./nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  imports = [ ../overlays ];

  programs.zsh.shellAliases = {
    "hm" = "home-manager";
  };
}

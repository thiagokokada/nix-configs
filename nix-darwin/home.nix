{ config, lib, pkgs, flake, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [
    flake.inputs.home.darwinModules.home-manager
  ];

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  users.users.${username} = {
    home = "/Users/${username}";
    # FIXME: why I can't use `pkgs.zsh` here?
    shell = "/run/current-system/sw/bin/zsh";
  };

  home-manager = {
    useUserPackages = true;
    users.${username} = ../home-manager/macos.nix;
    extraSpecialArgs = {
      inherit flake system;
      super = config;
    };
  };
}

{ config, lib, pkgs, self, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [
    self.inputs.home.darwinModules.home-manager
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
      inherit self system;
      super = config;
    };
  };
}

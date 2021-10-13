{ config, lib, pkgs, self, ... }:

let
  inherit (config.meta) username;
  inherit (config.users.users.${username}) home;
in
{
  imports = [
    ../../nix-darwin/home.nix
    ../../nix-darwin/system.nix
    ../../nix-darwin/meta.nix
    ../../cachix.nix
    ../../modules
    ../../overlays
  ];

  device = {
    type = "desktop";
    netDevices = [ "en0" ];
  };

  meta.configPath = "${home}/Projects/nix-configs";
}

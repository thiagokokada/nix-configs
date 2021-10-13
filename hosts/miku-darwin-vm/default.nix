{ config, lib, pkgs, self, ... }:

let
  inherit (config.meta) username;
  inherit (config.users.users.${username}) home;
in
{
  imports = [
    ../../nix-darwin
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

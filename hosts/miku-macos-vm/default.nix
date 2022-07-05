{ config, lib, pkgs, flake, ... }:

let
  inherit (config.meta) username;
  inherit (config.users.users.${username}) home;
in
{
  imports = [
    ../../nix-darwin
  ];

  device = {
    type = "desktop";
    netDevices = [ "en0" ];
  };

  meta.configPath = "${home}/Projects/nix-configs";
}

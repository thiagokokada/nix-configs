{ lib, osConfig, ... }:

let
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  services.kanshi.enable = true;
}

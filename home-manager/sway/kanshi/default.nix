{ super, lib, pkgs, ... }:

let
  hostName = super.networking.hostName or "";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  services.kanshi.enable = true;
}

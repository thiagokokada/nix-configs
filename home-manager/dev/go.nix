{ config, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  home = {
    packages = with pkgs; [ go ];
    sessionPath = [ "${homeDirectory}/.go/bin" ];
    sessionVariables = {
      GOPATH = "${homeDirectory}/.go";
    };
  };
}

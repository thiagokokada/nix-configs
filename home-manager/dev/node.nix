{ config, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  home = {
    packages = with pkgs; [
      nodejs
      yarn
    ];
    sessionPath = [ "${homeDirectory}/.npm-packages/bin" ];
    sessionVariables = rec {
      NPM_PACKAGES = "${homeDirectory}/.npm-packages";
      NODE_PATH = "${NPM_PACKAGES}/lib/node_modules:$NODE_PATH";
      MANPATH = "${NPM_PACKAGES}/share/man:$MANPATH";
    };
  };
}

{ config, pkgs, lib, ... }:

let
  inherit (config.home) homeDirectory;
in
{
  options.home-manager.dev.node.enable = lib.mkEnableOption "NodeJS config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.node.enable {
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
  };
}

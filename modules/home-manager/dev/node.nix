{
  config,
  pkgs,
  lib,
  ...
}:

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
        vscode-langservers-extracted
        yarn
      ];

      sessionPath = [ "${homeDirectory}/.npm-packages/bin" ];
      sessionVariables.NPM_PACKAGES = "${homeDirectory}/.npm-packages";
      sessionSearchVariables =
        let
          inherit (config.home.sessionVariables) NPM_PACKAGES;
        in
        {
          NODE_PATH = [ "${NPM_PACKAGES}/lib/node_modules" ];
          MANPATH = [ "${NPM_PACKAGES}/share/man" ];
        };
    };
  };
}

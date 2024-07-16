{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./clojure.nix
    ./go.nix
    ./nix.nix
    ./node.nix
    ./python.nix
  ];

  options.home-manager.dev.enable = lib.mkEnableOption "dev config";

  config = lib.mkIf config.home-manager.dev.enable {
    home.packages = with pkgs; [
      bash-language-server
      expect
      marksman
      shellcheck
    ];

    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = false;
      };
      zsh.initExtra = # bash
        # manually creating integrations since this is faster than calling
        # the `direnv hook zsh` itself during startup
        ''
          source ${
            pkgs.runCommand "direnv-hook-zsh" { } ''
              ${lib.getExe config.programs.direnv.package} hook zsh > $out
            ''
          }
        '';
    };
  };
}

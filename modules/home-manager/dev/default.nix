{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.meta) username;
in
{
  imports = [
    ./asdf.nix
    ./clojure.nix
    ./go.nix
    ./lua.nix
    ./nix.nix
    ./node.nix
    ./ollama.nix
    ./python.nix
  ];

  options.home-manager.dev.enable = lib.mkEnableOption "dev config" // {
    default = true;
  };

  config = lib.mkIf config.home-manager.dev.enable {
    home.packages = with pkgs; [
      bash-language-server
      expect
      marksman
      shellcheck
    ];

    programs = {
      adb.enable = true;
      direnv = {
        enable = true;
        enableZshIntegration = false;
      };
      tealdeer = {
        enable = true;
        settings = {
          display = {
            compact = false;
            use_pager = true;
          };
          updates = {
            auto_update = false;
          };
        };
      };
      zsh.initContent =
        # manually creating integrations since this is faster than calling
        # the `direnv hook zsh` itself during startup
        # bash
        ''
          source ${
            pkgs.runCommand "direnv-hook-zsh" { buildInputs = [ config.programs.direnv.package ]; } ''
              direnv hook zsh > $out
            ''
          }
        '';
    };

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

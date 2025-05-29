{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.dev.ollama;
in
{
  options.home-manager.dev.ollama = {
    enable = lib.mkEnableOption "Ollama config" // {
      default = config.home-manager.dev.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    # mods seems to ignore ~/.config/mods/mods.yml in darwin
    home.activation.symlinkModsConfig = lib.mkIf pkgs.stdenv.isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          run mkdir -p "$HOME/Library/Application Support/mods"
          run ln -sf "$HOME/.config/mods/mods.yml" "$HOME/Library/Application Support/mods/mods.yml"
        ''
    );

    programs = {
      mods = {
        enable = true;
        enableZshIntegration = false;
        settings = {
          default-model = "deepseek-r1";
          apis = {
            ollama = {
              base-url = "http://localhost:11434/api";
              models = {
                "deepseek-r1" = {
                  aliases = [ "deepseek" ];
                  max-input-chars = 650000;
                };
              };
            };
          };
        };
      };

      zsh.initContent =
        # bash
        ''
          source ${
            pkgs.runCommand "mods-hook-zsh" { buildInputs = [ config.programs.mods.package ]; } ''
              export HOME=$(mktemp -d)
              mods completion zsh > $out
            ''
          }
        '';
    };

    services.ollama = {
      enable = true;
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.dev.nix;
in
{
  options.home-manager.dev.nix = {
    enable = lib.mkEnableOption "Nix config" // {
      default = config.home-manager.dev.enable;
    };
    languageServer = lib.mkOption {
      type = lib.types.enum [
        "nixd"
        "nil"
      ];
      description = "Nix language server.";
      default = "nil";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        nix-tree
        nix-update
        nixfmt
        nurl
        nvd
        statix
      ]
      ++ lib.optionals (cfg.languageServer == "nil") [ nil ]
      ++ lib.optionals (cfg.languageServer == "nixd") [ nixd ];
  };
}

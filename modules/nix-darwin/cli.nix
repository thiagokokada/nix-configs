{ config, lib, ... }:

let
  cfg = config.nix-darwin.cli;
in
{
  options.nix-darwin.cli.enable = lib.mkEnableOption "CLI config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = false;
    };
  };
}

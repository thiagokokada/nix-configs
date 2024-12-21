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
      # Needed otherwise ZSH has no Nix environment setup
      enable = true;
      # Managed by zim-completion
      enableCompletion = false;
    };
  };
}

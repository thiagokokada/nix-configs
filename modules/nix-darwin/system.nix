{ config, lib, ... }:

let
  cfg = config.nix-darwin.system;
in
{
  options.nix-darwin.system.enable = lib.mkEnableOption "system config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    # To get zsh completion for system packages
    environment.pathsToLink = [ "/share/zsh" ];

    # Enable sudo via TouchID
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}

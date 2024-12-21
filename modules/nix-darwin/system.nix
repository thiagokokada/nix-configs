{ config, lib, ... }:

let
  cfg = config.nix-darwin.system;
in
{
  options.nix-darwin.system.enable = lib.mkEnableOption "system config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable { security.pam.enableSudoTouchIdAuth = true; };
}

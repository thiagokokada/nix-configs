{ lib, config, ... }:
{
  imports = [ ./virtualisation.nix ];

  options.nixos.dev.enable = lib.mkEnableOption "dev config";

  config = lib.mkIf config.nixos.dev.enable { };
}

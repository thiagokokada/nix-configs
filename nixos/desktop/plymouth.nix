{ config, lib, ... }:

{
  options.nixos.desktop.plymouth.enable = lib.mkDefaultOption "plymouth config";

  config = lib.mkIf config.nixos.desktop.plymouth.enable {
    boot.plymouth.enable = true;
  };
}

{ config, lib, ... }:

{
  options.nixos.desktop.plymouth.enable = lib.mkEnableOption "plymouth config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.plymouth.enable { boot.plymouth.enable = true; };
}

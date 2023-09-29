{ config, pkgs, lib, ... }:

{
  options.home-manager.dev.python.enable = lib.mkEnableOption "Python config";

  config = lib.mkIf config.home-manager.dev.python.enable {
    home.packages = with pkgs; [
      black
      pyright
      python3
    ];
  };
}

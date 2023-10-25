{ config, pkgs, lib, ... }:

{
  options.home-manager.dev.python.enable = lib.mkEnableOption "Python config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.python.enable {
    home.packages = with pkgs; [
      black
      # pyright
      python3
      python3Packages.jedi-language-server
      ruff
      ruff-lsp
    ];
  };
}

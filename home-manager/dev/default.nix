{ config, pkgs, lib, ... }:

{
  imports = [
    ./clojure.nix
    ./go.nix
    ./nix.nix
    ./node.nix
    ./python.nix
  ];

  options.home-manager.dev.enable = lib.mkEnableOption "dev config";

  config = lib.mkIf config.home-manager.dev.enable {
    home.packages = with pkgs; [
      bash-language-server
      expect
      marksman
      shellcheck
    ];

    programs.direnv.enable = true;
  };
}

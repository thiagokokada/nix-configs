{ config, pkgs, lib, ... }:

{
  imports = [
    ./clojure.nix
    ./go.nix
    ./node.nix
    ./python.nix
  ];

  options.home-manager.dev.enable = lib.mkDefaultOption "dev config";

  config = lib.mkIf config.home-manager.dev.enable {
    home.packages = with pkgs; [
      expect
      gcc
      nil
      nodePackages.bash-language-server
      shellcheck
    ];
  };
}

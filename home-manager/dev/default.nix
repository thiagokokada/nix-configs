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
      expect
      gcc
      marksman
      nodePackages.bash-language-server
      shellcheck
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # lorri is a faster direnv implementation
    services.lorri.enable = lib.mkIf pkgs.stdenv.isLinux true;
  };
}

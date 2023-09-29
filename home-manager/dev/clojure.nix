{ config, pkgs, lib, ... }:

{
  options.home-manager.dev.clojure.enable = lib.mkEnableOption "Clojure config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.clojure.enable {
    home.packages = with pkgs; [
      (babashka.override { withRlwrap = true; })
      clojure
      clojure-lsp
      (leiningen.override { inherit (clojure) jdk; })
    ];

    programs.java = {
      enable = true;
      package = pkgs.clojure.jdk;
    };
  };
}

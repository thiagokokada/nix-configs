{ pkgs, ... }:

let
  inherit (pkgs) babashka;
in
{
  imports = [ ./java.nix ];

  home.packages = with pkgs; [
    babashka
    clojure
    clojure-lsp
    leiningen
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "${pkgs.rlwrap}/bin/rlwrap ${babashka}/bin/bb";
  };
}

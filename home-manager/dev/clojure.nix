{ pkgs, ... }:

{
  home.packages = with pkgs; [
    babashka
    clojure
    clojure-lsp
    (leiningen.override { inherit (clojure) jdk; })
  ];
}

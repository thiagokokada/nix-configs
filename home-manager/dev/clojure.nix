{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (babashka.override { withRlwrap = true; })
    clojure
    clojure-lsp
    (leiningen.override { inherit (clojure) jdk; })
  ];
}

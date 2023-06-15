{ pkgs, ... }:

{
  home.packages = with pkgs; [
    babashka
    clojure-lsp
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "${pkgs.rlwrap}/bin/rlwrap ${pkgs.babashka}/bin/bb";
  };
}

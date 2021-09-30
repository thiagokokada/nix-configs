{ config, lib, pkgs, ... }:

{
  # Emacs overlay
  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    fd
    findutils
    gcc # needed by native compile
    hack-font
    noto-fonts
    pandoc
    stow
    unstable.clojure-lsp
    unstable.shellcheck
  ] ++ lib.optionals (!stdenv.isDarwin) [
    unstable.python-language-server
  ];

  programs.zsh.shellAliases = {
    "doom-up" = "nice doom upgrade";
    "em" = "run-bg emacs";
    "et" = "emacs -nw";
  };

  programs.emacs = {
    enable = true;
    package = with pkgs; if stdenv.isDarwin
    then emacsGcc
    else emacs-custom;
  };
}

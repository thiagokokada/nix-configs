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
    unstable.python-language-server
    unstable.rnix-lsp
    unstable.shellcheck
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-custom;
  };
}

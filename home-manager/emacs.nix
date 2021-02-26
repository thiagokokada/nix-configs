{ config, lib, pkgs, inputs, ... }:

{
  imports = [ inputs.nix-doom-emacs.hmModule ];

  # Emacs overlay
  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    fd
    findutils
    hack-font
    noto-fonts
    unstable.clojure-lsp
    unstable.python-language-server
    unstable.rnix-lsp
    unstable.shellcheck
  ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d;
    # emacsPackage = pkgs.emacsPgtkGcc;
  };

  programs.zsh = {
    shellAliases = {
      em = "run-bg emacs";
      et = "emacs -nw";
    };
    initExtra = ''
      emp() {
        local arg
        for arg in $@; do
          if [[ -d "$arg" ]]; then
            touch "$arg/.projectile"
          elif [[ -f "$arg" ]]; then
            local dirname=$(dirname )
            touch "$(dirname \"$arg\")/.projectile"
          fi
        done
        em $@
      }
    '';
  };
}

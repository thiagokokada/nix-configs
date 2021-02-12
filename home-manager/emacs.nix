{ config, lib, pkgs, ... }:

{
  # Emacs overlay
  home.packages = with pkgs; [
    clojure-lsp
    emacs-all-the-icons-fonts
    fd
    findutils
    fzf
    leiningen
    nixfmt
    python-language-server
    rnix-lsp
    shellcheck
    stow
  ];

  programs.emacs = {
    enable = true;
    package = (pkgs.emacsPackagesGen pkgs.emacsPgtkGcc).emacsWithPackages
      (epkgs: [ epkgs.vterm ]);
  };

  home.activation.stowEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ ! -d $HOME/.config/emacs ] && \
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone 'https://github.com/hlissner/doom-emacs/' "$HOME/.config/emacs"
  '';

  home.sessionPath = [ "$HOME/.config/emacs/bin" ];

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

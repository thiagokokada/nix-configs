{ config, lib, pkgs, ... }:

{
  # Emacs overlay
  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    fd
    findutils
    fzf
    hack-font
    noto-fonts
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

  home.activation.clone-doom-emacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ ! -d "$HOME/.config/emacs" ] \
      && "$DRY_RUN_CMD" ${pkgs.git}/bin/git clone 'https://github.com/hlissner/doom-emacs/' "$HOME/.config/emacs" \
      || true
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

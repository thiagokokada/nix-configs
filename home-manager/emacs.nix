{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/meta.nix ];

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

  home.sessionPath = [ "$HOME/.config/emacs/bin" ];

  programs.zsh = {
    initExtra = ''
      emp() {
        local p
        for p in $@; do
          if [[ -d "$p" ]]; then
            touch "$p"/.projectile
          elif [[ -f "$p" ]]; then
            touch $(dirname "$p")/.projectile
          fi
        done
        em $@
      }
    '';

    shellAliases = {
      "doom-up" = "nice doom upgrade";
      "em" = "run-bg emacs";
      "et" = "emacs -nw";
    };
  };

  programs.emacs = {
    enable = true;
    package = with pkgs; if stdenv.isDarwin
    then emacsGcc
    else emacs-custom;
  };

  xdg.configFile."doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.meta.configPath}/doom-emacs";

  home.activation.installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ ! -d $HOME/.config/emacs ] && \
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs/ $HOME/.config/emacs
  '';
}

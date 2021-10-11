{ config, lib, pkgs, ... }:

let
  doomConfigPath = "${config.meta.configPath}/doom-emacs";
in
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
    unstable.rnix-lsp
    unstable.shellcheck
  ] ++ lib.optionals (!stdenv.isDarwin) [
    unstable.python-language-server
  ];

  home.sessionPath = [ "$HOME/.config/emacs/bin" ];

  programs.zsh = {
    initExtra =
      let
        emacs = "${config.programs.emacs.package}/bin/emacs";
      in
      ''
        em() { ${emacs} "$@" &>/dev/null &! }
        et() { ${emacs} -nw "$@" }
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
      "doom-up!" = "nice doom upgrade";
    };
  };

  programs.emacs = {
    enable = true;
    package = with pkgs; if stdenv.isDarwin
    then emacs # TODO: change to emacsGcc when it is more stable
    else emacs-custom;
  };

  xdg.configFile."doom".source =
    config.lib.file.mkOutOfStoreSymlink doomConfigPath;

  home.activation = {
    installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      readonly emacs_dir="${config.home.homeDirectory}/.config/emacs";
      [ ! -d "$emacs_dir" ] && \
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs/ "$emacs_dir"
    '';

    checkDoomConfigLocation = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ ! -e "${config.xdg.configFile."doom".target}" ]; then
        >&2 echo "[ERROR] doom-emacs config is pointing to a non-existing path: ${doomConfigPath}"
        $DRY_RUN_CMD exit 1
      fi
    '';
  };
}

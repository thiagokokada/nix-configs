{ config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
  doomConfigPath = "${config.meta.configPath}/home-manager/emacs/doom-emacs";
in
{
  imports = [ ../../modules/meta.nix ];

  # Emacs overlay
  home = {
    packages = with pkgs; [
      # doom-emacs main deps
      emacs-all-the-icons-fonts
      fd
      findutils
      ripgrep

      # needed by native compile
      gcc

      # font for my config
      fira-code
      hack-font
      noto-fonts

      # markdown mode
      pandoc

      # lsp
      unstable.clojure-lsp
      unstable.pyright
      unstable.rnix-lsp

      # shell
      unstable.shellcheck
    ];

    sessionPath = [ "${homeDirectory}/.config/emacs/bin" ];
  };

  programs.zsh = {
    initExtra =
      let
        emacs = "${config.programs.emacs.package}/bin/emacs";
      in
      ''
        ${pkgs.lib.utils.makeBgCmd "em" emacs}
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

  programs.emacs = with pkgs; let
    emacsPkg =
      if stdenv.isDarwin then
        emacsGcc
      else emacsPgtkGcc;
    # TODO: remove this after 22.05
    emacsPackagesFor' =
      if builtins.hasAttr "emacsPackagesFor" pkgs
      then pkgs.emacsPackagesFor
      else pkgs.emacsPackagesGen;
    emacs-custom = with pkgs; (emacsPackagesFor' emacsPkg).emacsWithPackages
      (epkgs: with epkgs; [ vterm ]);
  in
  {
    enable = true;
    package = emacs-custom;
  };

  xdg.configFile."doom".source =
    config.lib.file.mkOutOfStoreSymlink doomConfigPath;

  xdg.configFile.".tree-sitter".source = (pkgs.runCommand "grammars" { } ''
    mkdir -p $out/bin
    ${lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so") pkgs.tree-sitter.builtGrammars)};
  '');

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

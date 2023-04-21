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
      (run-bg-alias "em" "${config.programs.emacs.package}/bin/emacs")
      (writeShellScriptBin "et" "${config.programs.emacs.package}/bin/emacs -nw $@")
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
    ];

    sessionPath = [ "${homeDirectory}/.config/emacs/bin" ];
  };

  programs.zsh.shellAliases = {
    "doom-up!" = "nice doom upgrade";
  };

  programs.emacs = with pkgs; let
    emacsPkg =
      if stdenv.isDarwin then
        emacsUnstable
      else
        emacsUnstablePgtk.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./disable_pgtk_display_x_warning.patch ];
        });
    emacs-custom = with pkgs; (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages
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
      (lib.mapAttrsToList
        (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so")
        pkgs.tree-sitter.builtGrammars)};
  '');

  home.activation = {
    installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      readonly emacs_dir="${homeDirectory}/.config/emacs";
      [ ! -d "$emacs_dir" ] && \
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/hlissner/doom-emacs/ "$emacs_dir"
    '';

    checkDoomConfigLocation = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ ! -e "${doomConfigPath}" ]; then
        >&2 echo "[ERROR] doom-emacs config is pointing to a non-existing path: ${doomConfigPath}"
        $DRY_RUN_CMD exit 1
      fi
    '';
  };
}

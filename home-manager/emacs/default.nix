{ flake, config, lib, pkgs, ... }:

{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  # Emacs overlay
  home = {
    file.".emacs.d/early-init.el".source = ./early-init.el;
    packages = with pkgs; [
      (run-bg-alias "em" "${config.programs.doom-emacs.package}/bin/emacs")
      (writeShellScriptBin "et" "${config.programs.doom-emacs.package}/bin/emacs -nw $@")
      # font for my config
      fira-code
      hack-font
      noto-fonts

      # markdown mode
      pandoc

      # lsp
      unstable.rnix-lsp

      # shell
      shellcheck
    ];
  };

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom-emacs;
    emacsPackage = with pkgs;
      if stdenv.isDarwin then
        emacsNativeComp
      else emacsPgtkNativeComp;
    emacsPackagesOverlay = final: prev: {
      ts-fold = prev.ts;
      tree-sitter-langs = prev.tree-sitter-langs.override { plugins = pkgs.unstable.tree-sitter.allGrammars; };
    };
    extraPackages = with pkgs; [
      fd
      findutils
      ripgrep
    ];
  };
}

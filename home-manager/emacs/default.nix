{ flake, config, lib, pkgs, ... }:

{
  imports = [ flake.inputs.nix-doom-emacs.hmModule ];

  # Emacs overlay
  home = {
    packages = with pkgs; [
      (run-bg-alias "em" "${config.programs.doom-emacs.package}/bin/emacs")
      (writeShellScriptBin "et" "${config.programs.doom-emacs.package}/bin/emacs -nw $@")
      # font for my config
      fira-code
      hack-font
      noto-fonts
    ];
  };

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom-emacs;
    emacsPackage = with pkgs;
      if stdenv.isDarwin then
        emacsGitNativeComp
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

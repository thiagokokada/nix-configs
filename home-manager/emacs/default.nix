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

  programs.doom-emacs = rec {
    enable = true;
    doomPrivateDir = ./doom-emacs;
    emacsPackage = with pkgs;
      if stdenv.isDarwin then
        emacsGitNativeComp
      else emacsPgtkNativeComp;
    # FIXME: why `tsc` is not being added to `load-path`?
    extraConfig = with pkgs.emacsPackagesFor emacsPackage; ''
      (add-to-list 'load-path "${tsc}/share/emacs/site-lisp/elpa/${tsc.name}/")
    '';
    extraPackages = with pkgs; [
      fd
      findutils
      ripgrep
    ];
  };
}

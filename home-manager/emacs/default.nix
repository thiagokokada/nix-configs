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
    doomPackageDir = pkgs.linkFarm "doom-packages" [
      { name = "config.el"; path = pkgs.emptyFile; }
      { name = "init.el"; path = ./doom-emacs/init.el; }
      { name = "packages.el"; path = ./doom-emacs/packages.el; }
    ];
    emacsPackage = pkgs.emacsUnstable;
    emacsPackagesOverlay = final: prev: {
      vterm = prev.vterm.overrideAttrs (oldAttrs: {
        cmakeFlags = [
          "-DEMACS_SOURCE=${emacsPackage.src}"
          "-DUSE_SYSTEM_LIBVTERM=ON"
        ];
      });
    };
    extraPackages = with pkgs; [
      fd
      findutils
      ripgrep
    ];
  };
}

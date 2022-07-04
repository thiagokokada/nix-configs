{ self, config, lib, pkgs, ... }:

{
  imports = [ self.inputs.nix-doom-emacs.hmModule ];

  # Emacs overlay
  home = {
    packages = with pkgs; [
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

  programs.zsh = {
    initExtra =
      let
        emacs = "${config.programs.doom-emacs.package}/bin/emacs";
      in
      ''
        ${pkgs.lib.makeBgCmd "em" emacs}
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
  };

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom-emacs;
    emacsPackage = with pkgs;
      if stdenv.isDarwin then
        emacsNativeComp
      else emacsPgtkNativeComp;
    extraPackages = with pkgs; [
      fd
      findutils
      ripgrep
    ];
  };
}

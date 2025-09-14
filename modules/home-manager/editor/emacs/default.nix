{
  flake,
  config,
  lib,
  pkgs,
  ...
}:

let
  emacs = config.programs.doom-emacs.finalEmacsPackage;
in
{
  imports = [ flake.inputs.nix-doom-emacs-unstraightened.homeModule ];

  options.home-manager.editor.emacs.enable = lib.mkEnableOption "Emacs config" // {
    default = config.home-manager.editor.enable && config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.editor.emacs.enable {
    home = {
      packages = with pkgs; [
        (run-bg-alias "em" "${lib.getExe emacs}")
        (writeShellScriptBin "et" "${lib.getExe emacs} -nw $@")
      ];
    };

    programs.doom-emacs = {
      enable = true;
      doomDir = ./doom-emacs;

      emacs =
        with pkgs;
        if stdenv.isDarwin then
          emacs30
        else
          emacs30-pgtk.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./disable_pgtk_display_x_warning.patch ];
          });

      extraPackages =
        epkgs: with epkgs; [
          treesit-grammars.with-all-grammars
          vterm
        ];

      extraBinPackages = with pkgs; [
        # doom-emacs main deps
        emacs-all-the-icons-fonts
        fd
        findutils
        ripgrep

        # font for my config
        fira-code
        hack-font
        noto-fonts
      ];
    };
  };
}

{ flake, config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
  emacs' = with pkgs;
    if stdenv.isDarwin then
      emacsUnstable
    else
      emacsUnstablePgtk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./disable_pgtk_display_x_warning.patch ];
      });
  emacs-custom = with pkgs; (pkgs.emacsPackagesFor emacs').emacsWithPackages
    (epkgs: with epkgs; [ vterm ]);
in
{
  imports = [ ../../modules/meta.nix ];

  # Emacs overlay
  home = {
    activation.runDoomSync = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.systemd}/bin/systemctl start --user doom-sync.service --no-block
    '';

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
    sessionVariables.EMACSDIR = "${homeDirectory}/.config/emacs";
  };

  programs.emacs = {
    enable = true;
    package = emacs-custom;
  };

  xdg.configFile."doom".source = ./doom-emacs;
  xdg.configFile."emacs" = {
    source = flake.inputs.doomemacs;
    recursive = true;
  };

  xdg.configFile.".tree-sitter".source = (pkgs.runCommand "grammars" { } ''
    mkdir -p $out/bin
    ${lib.concatStringsSep "\n"
      (lib.mapAttrsToList
        (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so")
        pkgs.tree-sitter.builtGrammars)};
  '');

  systemd.user.services.doom-sync = {
    Unit = {
      After = [ "network.target" ];
      Description = "Sync doomemacs config";
    };

    Service = with pkgs; {
      Nice = "15";
      Environment = [
        "HOME=${homeDirectory}"
        "EMACSDIR=${config.home.sessionVariables.EMACSDIR}"
        "PATH=${lib.makeBinPath [ bash emacs-custom gcc git ]}"
      ];
      ExecStart = "${flake.inputs.doomemacs}/bin/doom sync";
      ExecStartPost = "${libnotify}/bin/notify-send 'Finished sync' 'Doom Emacs is ready!'";
      Type = "oneshot";
    };
  };
}

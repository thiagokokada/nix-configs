{
  flake,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.home) homeDirectory;
  inherit (config.home.sessionVariables) EMACSDIR;
  emacs' =
    with pkgs;
    if stdenv.isDarwin then
      emacs29
    else
      emacs29-pgtk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./disable_pgtk_display_x_warning.patch ];
      });
in
{
  options.home-manager.editor.emacs.enable = lib.mkEnableOption "Emacs config" // {
    default =
      config.home-manager.editor.enable
      && (config.home-manager.desktop.enable || config.home-manager.darwin.enable);
  };

  config = lib.mkIf config.home-manager.editor.emacs.enable {
    home = {
      file.".tree-sitter".source = pkgs.runCommand "grammars" { } ''
        mkdir -p $out/bin
        ${
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so"
            ) pkgs.tree-sitter.builtGrammars
          )
        };
      '';

      packages = with pkgs; [
        (run-bg-alias "em" "${lib.getExe config.programs.emacs.package}")
        (writeShellScriptBin "et" "${lib.getExe config.programs.emacs.package} -nw $@")
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

      sessionVariables.EMACSDIR = "${homeDirectory}/.config/emacs";
      sessionPath = [ "${homeDirectory}/.config/emacs/bin" ];
    };

    programs.emacs = {
      enable = true;
      package = emacs';
    };

    xdg.configFile."doom".source = ./doom-emacs;

    systemd.user.services.doom-sync = {
      Unit = {
        After = [ "network.target" ];
        Description = "Sync doomemacs config";
      };
      Service = with pkgs; {
        Nice = "15";
        Environment = [
          "PATH=${
            lib.makeBinPath [
              bash
              emacs'
              gcc
              git
            ]
          }"
          "EMACSDIR=${EMACSDIR}"
        ];
        ExecStart = "${EMACSDIR}/bin/doom sync -u --no-color";
        ExecStartPre = "${lib.getExe libnotify} 'Starting sync' 'Doom Emacs config is syncing...'";
        ExecStartPost = "${lib.getExe libnotify} 'Finished sync' 'Doom Emacs is ready!'";
        Type = "oneshot";
      };
    };

    home.activation = {
      # TODO: check doomemacs commit and only update if it is outdated
      installDoom = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        ${lib.getExe pkgs.rsync} -Er --chmod=u=rwX --exclude='.local/' --mkpath --delete ${flake.inputs.doomemacs}/ ${EMACSDIR}/
      '';
      runDoomSync = lib.mkIf pkgs.stdenv.isLinux (
        lib.hm.dag.entryAfter [ "installDoom" ] ''
          ${lib.getExe' pkgs.systemd "systemctl"} start --user doom-sync.service --no-block
        ''
      );
    };
  };
}

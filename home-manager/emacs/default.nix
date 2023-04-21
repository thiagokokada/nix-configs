{ flake, config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
  inherit (config.home.sessionVariables) EMACSDIR;
  doomRepo = "https://github.com/doomemacs/doomemacs";
  doomConfigPath = "${config.meta.configPath}/home-manager/emacs/doom-emacs";
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

    sessionVariables.EMACSDIR = "${homeDirectory}/.config/emacs";
    sessionPath = [ "${homeDirectory}/.config/emacs/bin" ];
  };

  programs.emacs = {
    enable = true;
    package = emacs-custom;
  };

  xdg.configFile = {
    "doom".source = config.lib.file.mkOutOfStoreSymlink doomConfigPath;
    ".tree-sitter".source = (pkgs.runCommand "grammars" { } ''
      mkdir -p $out/bin
      ${lib.concatStringsSep "\n"
        (lib.mapAttrsToList
          (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so")
          pkgs.tree-sitter.builtGrammars)};
    '');
  };

  systemd.user.services.doom-sync = {
    Unit = {
      After = [ "network.target" ];
      Description = "Sync doomemacs config";
    };
    Service = with pkgs; {
      Nice = "15";
      Environment = [ "PATH=${lib.makeBinPath [ bash emacs-custom gcc git ]}" ];
      ExecStart = "${EMACSDIR}/bin/doom sync --no-color";
      ExecStartPre = "${libnotify}/bin/notify-send 'Starting sync' 'Doom Emacs config is syncing...'";
      ExecStartPost = "${libnotify}/bin/notify-send 'Finished sync' 'Doom Emacs is ready!'";
      Type = "oneshot";
    };
  };

  home.activation = {
    checkDoomConfigLocation = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      if [ ! -e "${doomConfigPath}" ]; then
        >&2 echo "[ERROR] doom-emacs config is pointing to a non-existing path: ${doomConfigPath}"
        $DRY_RUN_CMD exit 1
      fi
    '';
    installDoom = lib.hm.dag.entryAfter [ "checkDoomConfigLocation" ] ''
      [ ! -d "${EMACSDIR}" ] && \
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "${doomRepo}" "${EMACSDIR}"
    '';
    runDoomSync = lib.hm.dag.entryAfter [ "installDoom" ] ''
      ${pkgs.systemd}/bin/systemctl start --user doom-sync.service --no-block
    '';
  };
}

{ flake, config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;
  inherit (config.home.sessionVariables) EMACSDIR;
  emacs' = with pkgs;
    if stdenv.isDarwin then
      emacs-unstable
    else
      emacs-unstable-pgtk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./disable_pgtk_display_x_warning.patch ];
      });
  emacs-custom = with pkgs; (pkgs.emacsPackagesFor emacs').emacsWithPackages
    (epkgs: with epkgs; [ vterm ]);
in
{
  imports = [ ../../modules/meta.nix ];

  # Emacs overlay
  home = {
    file.".tree-sitter".source = (pkgs.runCommand "grammars" { } ''
      mkdir -p $out/bin
      ${lib.concatStringsSep "\n"
        (lib.mapAttrsToList
          (name: src: "name=${name}; ln -s ${src}/parser $out/bin/\${name#tree-sitter-}.so")
          pkgs.tree-sitter.builtGrammars)};
    '');

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

  xdg.configFile."doom".source = ./doom-emacs;

  systemd.user.services.doom-sync = {
    Unit = {
      After = [ "network.target" ];
      Description = "Sync doomemacs config";
    };
    Service = with pkgs; {
      Nice = "15";
      Environment = [
        "PATH=${lib.makeBinPath [ bash emacs-custom gcc git ]}"
        "EMACSDIR=${EMACSDIR}"
      ];
      ExecStart = "${EMACSDIR}/bin/doom sync -u --no-color";
      ExecStartPre = "${libnotify}/bin/notify-send 'Starting sync' 'Doom Emacs config is syncing...'";
      ExecStartPost = "${libnotify}/bin/notify-send 'Finished sync' 'Doom Emacs is ready!'";
      Type = "oneshot";
    };
  };

  home.activation = {
    # TODO: check doomemacs commit and only update if it is outdated
    installDoom = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.rsync}/bin/rsync -Er --chmod=u=rwX --exclude='.local/' --mkpath --delete ${flake.inputs.doomemacs}/ ${EMACSDIR}/
    '';
    runDoomSync = lib.mkIf (pkgs.stdenv.isLinux)
      (lib.hm.dag.entryAfter [ "installDoom" ] ''
        ${pkgs.systemd}/bin/systemctl start --user doom-sync.service --no-block
      '');
  };
}

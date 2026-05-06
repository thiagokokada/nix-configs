{ config, lib, ... }:

let
  cfg = config.home-manager.meta.restoreBackups;
in
{
  options.home-manager.meta.restoreBackups = {
    backupFileExtension = lib.mkOption {
      description = "File extension to remove before activation.";
      type = with lib.types; nullOr str;
      default = null;
    };
  };

  config = lib.mkIf (cfg.backupFileExtension != null) {
    home.activation.restoreBackups =
      lib.hm.dag.entryAfter [ "linkGeneration" ]
        # bash
        ''
          restoreBackup() {
            local relativePath="$1"
            local base="$HOME/$relativePath"
            local backup="$base.${cfg.backupFileExtension}"

            if [[ ! -e "$backup" ]]; then
              return
            fi

            if [[ ! -e "$base" ]]; then
              echo "Renaming: $backup -> $base"
              run mv $VERBOSE_ARG -- "$backup" "$base"
            else
              echo "Skipping: $backup (because $base exists)"
            fi
          }

          restoreOldGenerationBackups() {
            local oldGenFiles

            if [[ ! -v oldGenPath || ! -e "$oldGenPath/home-files" ]]; then
              return
            fi

            # Only restore backups for paths that were managed by the previous
            # Home Manager generation. This is mainly for switching between
            # specialisations: if the old generation managed a file and the new
            # one does not, Home Manager leaves a .hm-backup behind and we
            # restore it here after link cleanup.
            oldGenFiles="$(readlink -e "$oldGenPath/home-files")"
            find "$oldGenFiles" '(' -type f -or -type l ')' -printf '%P\0' \
              | while IFS= read -r -d "" relativePath; do
                restoreBackup "$relativePath"
              done
          }

          restoreOldGenerationBackups
          unset -f restoreBackup restoreOldGenerationBackups
        '';
  };
}

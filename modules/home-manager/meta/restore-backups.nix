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
          (find "$HOME" -type f -name "*.${cfg.backupFileExtension}" 2>/dev/null || true) | while IFS= read -r file; do
            base="''${file%.${cfg.backupFileExtension}}"
            if [[ ! -e "$base" ]]; then
              echo "Renaming: $file -> $base"
              run mv $VERBOSE_ARG -- "$file" "$base"
            else
              echo "Skipping: $file (because $base exists)"
            fi
          done
        '';
  };
}

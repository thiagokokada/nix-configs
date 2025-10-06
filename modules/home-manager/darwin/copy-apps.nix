{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.darwin.copyApps;
in
{
  options.home-manager.darwin.copyApps.enable =
    lib.mkEnableOption "copy macOS apps to ~/Applications"
    // {
      default = config.home-manager.darwin.enable;
    };

  config = lib.mkIf cfg.enable {
    # https://github.com/nix-darwin/nix-darwin/pull/1396#issuecomment-2908304517
    # https://github.com/PedroHLC/system-setup/blob/6f41b5e8740da7fbe85d37c0d15f8fe464d4bbc0/home-configurations/foreign/trampolines.nix
    home.activation.copyApplications =
      let
        applications = pkgs.buildEnv {
          name = "user-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "installPackages" ]
        # bash
        ''
          set -e

          targetFolder=${lib.strings.escapeShellArg config.targets.darwin.linkApps.directory}

          echo "setting up ~/$targetFolder..." >&2

          ourLink () {
            local link
            link=$(readlink "$1")
            [ -L "$1" ] && [ "''${link#*-}" = "home-manager-files/$targetFolder" ]
          }

          if [ -e "$targetFolder" ] && ourLink "$targetFolder"; then
            run rm "$targetFolder"
          fi

          run mkdir -p "$targetFolder"

          rsyncFlags=(
            --archive
            # mtime is standardized in the nix store, which would leave only file size to distinguish files.
            # Thus we need checksums, despite the speed penalty.
            --checksum
            # Converts all symlinks pointing outside of the copied tree (thus unsafe) into real files and directories.
            # This neatly converts all the symlinks pointing to application bundles in the nix store into
            # real directories, without breaking any relative symlinks inside of application bundles.
            # This is good enough, because the make-symlinks-relative.sh setup hook converts all $out internal
            # symlinks to relative ones.
            --copy-unsafe-links
            --delete
            --no-perms
            --no-group
            --no-owner
          )

          run ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" $VERBOSE_ARG ${applications}/Applications/ "$targetFolder"
        '';

    # Disable old style linking of applications in home-manager
    targets.darwin.linkApps.enable = false;
  };
}

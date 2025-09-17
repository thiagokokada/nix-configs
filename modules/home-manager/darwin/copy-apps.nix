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
    home.activation.copyApplications =
      let
        targetFolder = "${config.home.homeDirectory}/Applications/Home Manager Apps";
        homeApps = pkgs.buildEnv {
          name = "home-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        # Set up home applications.
        echo "Setting up ${targetFolder}..." >&2

        # Clean up old style symlinks
        if [ -e "${targetFolder}" ] && [ -L "${targetFolder}" ]; then
          rm "${targetFolder}"
        fi
        mkdir -p "${targetFolder}"

        rsyncFlags=(
          # mtime is standardized in the nix store, which would leave only file size to distinguish files.
          # Thus we need checksums, despite the speed penalty.
          --checksum
          # Converts all symlinks pointing outside of the copied tree (thus unsafe) into real files and directories.
          # This neatly converts all the symlinks pointing to application bundles in the nix store into
          # real directories, without breaking any relative symlinks inside of application bundles.
          # This is good enough, because the make-symlinks-relative.sh setup hook converts all $out internal
          # symlinks to relative ones.
          --copy-unsafe-links
          --archive
          --delete
          # https://github.com/nix-community/home-manager/issues/1341#issuecomment-3081211229
          # --chmod=-w
          --no-group
          --no-owner
        )
        ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${homeApps}/Applications/ "${targetFolder}"
      '';

    # Disable old style linking of applications in home-manager
    targets.darwin.linkApps.enable = false;
  };
}

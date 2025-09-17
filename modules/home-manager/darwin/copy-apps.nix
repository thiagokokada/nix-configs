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
        targetDir = "${config.home.homeDirectory}/Applications/Home Manager Apps";
        homeApps = pkgs.buildEnv {
          name = "home-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Set up home applications.
        echo "Setting up ${targetDir}..." >&2

        # Clean up old style symlinks
        if [ -e "${targetDir}" ] && [ -L "${targetDir}" ]; then
          rm "${targetDir}"
        fi
        mkdir -p "${targetDir}"

        rsyncFlags=(
          --checksum
          --copy-unsafe-links
          --archive
          --delete
          --chmod=-w
          --no-group
          --no-owner
        )
        ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${homeApps}/Applications/ "${targetDir}"
      '';

    # Disable old style linking of applications in home-manager
    targets.darwin.linkApps.enable = false;
  };
}

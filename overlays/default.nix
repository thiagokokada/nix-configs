{ inputs, outputs, ... }:
final: prev:

let
  inherit (prev.stdenv.hostPlatform) system;
in
{
  # namespaces
  libEx = outputs.lib;

  # custom packages
  inherit (inputs.gh-gfm-preview.packages.${system}) gh-gfm-preview;
  inherit (inputs.gitk-rs.packages.${system}) gitk-rs;
  inherit (inputs.nix-alien.packages.${system}) nix-alien;

  nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

  nixos-cleanup = final.nix-cleanup.override { isNixOS = true; };

  darwin-cleanup = final.nix-cleanup.override { isNixDarwin = true; };

  mkWallpaperImgur = prev.callPackage ../packages/wallpapers/mkWallpaperImgur.nix { };

  nix-whereis = prev.callPackage ../packages/nix-whereis { };

  realise-symlink = prev.writeShellApplication {
    name = "realise-symlink";
    runtimeInputs = with final; [ coreutils ];
    text = ''
      for file in "$@"; do
        if [[ -L "$file" ]]; then
          if [[ -d "$file" ]]; then
            tmpdir="''${file}.tmp"
            mkdir -p "$tmpdir"
            cp --verbose --recursive "$file"/* "$tmpdir"
            unlink "$file"
            mv "$tmpdir" "$file"
            chmod --changes --recursive +w "$file"
          else
            cp --verbose --remove-destination "$(readlink "$file")" "$file"
            chmod --changes +w "$file"
          fi
        else
          >&2 echo "Not a symlink: $file"
          exit 1
        fi
      done
    '';
  };

  run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

  wallpapers = final.callPackage ../packages/wallpapers { };
}

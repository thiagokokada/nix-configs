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
  inherit (inputs.gitk-go.packages.${system}) gitk-go;
  inherit (inputs.nix-alien.packages.${system}) nix-alien;

  # https://github.com/NixOS/nixpkgs/issues/507531
  direnv = prev.direnv.overrideAttrs (_: {
    doCheck = !prev.stdenv.isDarwin;
  });

  neovim-standalone =
    let
      hostName = "neovim-standalone";
      hm = outputs.lib.mkHomeConfig {
        inherit hostName system;
        configuration = {
          home-manager = {
            cli.icons.enable = false;
            dev = {
              enable = true;
              nix.enable = true;
            };
            editor.neovim = {
              enable = true;
              lsp.enable = true;
              treeSitter.enable = true;
            };
          };
          home.stateVersion = "25.11";
        };
      };
    in
    hm.homeConfigurations.${hostName}.config.home-manager.editor.neovim.standalonePackage;

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

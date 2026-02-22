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

  run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

  wallpapers = final.callPackage ../packages/wallpapers { };

  wineasio = prev.callPackage ../packages/wineasio { };
}

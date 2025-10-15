{ inputs, outputs, ... }:
final: prev:

{
  # namespaces
  libEx = outputs.lib;

  # custom packages
  arandr = prev.arandr.overrideAttrs (_: {
    src = inputs.arandr;
  });

  inherit (inputs.home-manager.packages.${prev.system}) home-manager;

  inherit (inputs.gh-gfm-preview.packages.${prev.system}) gh-gfm-preview;

  neovim-standalone =
    let
      hostName = "neovim-standalone";
      hm = outputs.lib.mkHomeConfig {
        inherit hostName;
        inherit (prev) system;
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
}

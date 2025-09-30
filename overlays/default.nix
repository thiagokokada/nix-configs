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

  open-browser = prev.callPackage ../packages/open-browser { };

  neovim-standalone =
    outputs.homeConfigurations.home-linux.config.home-manager.editor.neovim.standalonePackage;

  nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

  nixos-cleanup = final.nix-cleanup.override { isNixOS = true; };

  darwin-cleanup = final.nix-cleanup.override { isNixDarwin = true; };

  mkWallpaperImgur = prev.callPackage ../packages/wallpapers/mkWallpaperImgur.nix { };

  nix-whereis = prev.callPackage ../packages/nix-whereis { };

  run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

  wallpapers = final.callPackage ../packages/wallpapers { };
}

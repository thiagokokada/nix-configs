{ inputs, outputs }:
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
    let
      hostname = "neovim-standalone";
      hm =
        (outputs.lib.mkHomeConfig {
          inherit hostname;
          inherit (prev) system;
          configuration = {
            home-manager = {
              cli.icons.enable = false;
              dev.nix.enable = true;
              editor.neovim = {
                lsp.enable = true;
                treeSitter.enable = true;
              };
            };
            home.stateVersion = "25.11";
          };
        }).homeConfigurations.${hostname};
    in
    hm.config.programs.neovim.finalPackage.override {
      luaRcContent = hm.config.xdg.configFile."nvim/init.lua".text;
      wrapRc = true;
    };

  nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

  nixos-cleanup = final.nix-cleanup.override { isNixOS = true; };

  darwin-cleanup = final.nix-cleanup.override { isNixDarwin = true; };

  nix-whereis = prev.callPackage ../packages/nix-whereis { };

  run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

  wallpapers = prev.callPackage ../packages/wallpapers { };
}

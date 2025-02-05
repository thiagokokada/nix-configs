{ flake }:
final: prev:

let
  inherit (flake) outputs inputs;
in
outputs.lib.recursiveMergeAttrs [
  {
    # namespaces
    libEx = outputs.lib;

    # custom packages
    arandr = prev.arandr.overrideAttrs (_: {
      src = inputs.arandr;
    });

    anime4k = prev.callPackage ../packages/anime4k { };

    inherit (inputs.home-manager.packages.${prev.system}) home-manager;

    open-browser = prev.callPackage ../packages/open-browser { };

    neovim-standalone =
      let
        hostname = "neovim";
        hm =
          (outputs.lib.mkHomeConfig {
            inherit hostname;
            inherit (prev) system;
            extraModules = [
              {
                home-manager = {
                  dev.nix.enable = true;
                  editor.neovim = {
                    icons.enable = false;
                    lsp.enable = true;
                    treeSitter.enable = true;
                  };
                };
              }
            ];
          }).homeConfigurations.${hostname};
      in
      hm.config.programs.neovim.finalPackage.override {
        luaRcContent = hm.config.xdg.configFile."nvim/init.lua".text;
        wrapRc = true;
      };

    nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

    nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

    nix-whereis = prev.callPackage ../packages/nix-whereis { };

    run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

    wallpapers = prev.callPackage ../packages/wallpapers { };
  }
]

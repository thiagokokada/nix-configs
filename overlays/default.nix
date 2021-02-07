{ pkgs, inputs, system, ... }:

{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = { allowUnfree = true; };
      };

      emacsCustom = (pkgs.emacsPackagesGen pkgs.emacsPgtkGcc).emacsWithPackages
        (epkgs: [ epkgs.vterm ]);

      neovimCustom = pkgs.neovim.override ({
        withNodeJs = true;
        vimAlias = true;
        viAlias = true;
      });
    })
  ];
}

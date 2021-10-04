{ pkgs, lib, inputs, system, ... }:

{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      emacs-custom = with final; (emacsPackagesGen emacsPgtkGcc).emacsWithPackages
        (epkgs: with epkgs; [ vterm ]);

      linux-zen-with-muqss = with prev;
        linuxPackagesFor (linux_zen.override {
          structuredExtraConfig = with lib.kernel; {
            PREEMPT = yes;
            PREEMPT_VOLUNTARY = lib.mkForce no;
            SCHED_MUQSS = yes;
          };
          ignoreConfigErrors = true;
        });

      neovim-custom = prev.neovim.override ({
        withNodeJs = true;
        vimAlias = true;
        viAlias = true;
      });

      open-browser = prev.callPackage ../packages/open-browser { };

      # TODO: remove it from 21.11
      pamixer = final.unstable.pamixer;
      rar = final.unstable.rar;
    })
  ];
}

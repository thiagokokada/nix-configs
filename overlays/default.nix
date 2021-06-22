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

      pamixer-unstable = with prev; pamixer.overrideAttrs (oldAttrs: {
        version = "unstable-2021-03-29";
        src = fetchFromGitHub {
          owner = "cdemoulins";
          repo = "pamixer";
          rev = "4ea2594cb8c605dccd00a381ba19680eba368e94";
          sha256 = "sha256-kV4wIxm1WZvqqyfmgQ2cSbRJwJR154OW0MMDg2ntf6g=";
        };
      });

      plex = final.unstable.plex;
    })
  ];
}

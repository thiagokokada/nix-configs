{ pkgs, lib, inputs, system, ... }:

{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: rec {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      # Backport from unstable to have Python 3 version
      cpuset-with-patch = with unstable;
        cpuset.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            (fetchpatch {
              url =
                "https://github.com/lpechacek/cpuset/files/5792001/cpuset2.txt";
              sha256 = "0rrgfixznhyymahakz31i396nj26qx9mcdavhm5cpkcfiqmk8nzl";
            })
          ];
        });

      emacs-custom = (pkgs.emacsPackagesGen pkgs.emacsPgtkGcc).emacsWithPackages
        (epkgs: [ epkgs.vterm ]);

      fzf = unstable.fzf;

      linux-zen-with-muqss = with final;
        linuxPackagesFor (linux_zen.override {
          structuredExtraConfig = with lib.kernel; {
            PREEMPT = yes;
            PREEMPT_VOLUNTARY = lib.mkForce no;
            SCHED_MUQSS = yes;
          };
          ignoreConfigErrors = true;
        });

      neovim-custom = pkgs.neovim.override ({
        withNodeJs = true;
        vimAlias = true;
        viAlias = true;
      });

      pamixer-unstable = pkgs.pamixer.overrideAttrs (oldAttrs: {
        version = "unstable-2020-01-06";
        src = pkgs.fetchFromGitHub {
          owner = "cdemoulins";
          repo = "pamixer";
          rev = "7f245fd1a064147266a9118bdbadf52fdc1343ff";
          sha256 = "sha256-m/bdXEKFIOyXTpzE8p7PIDk3Uril35+ljckSUQJLDvI=";
        };
      });

      plex = unstable.plex;
    })
  ];
}

{ pkgs, lib, flake, system, ... }:

let
  inherit (flake) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      # namespaces
      lib = prev.lib.extend (finalLib: prevLib:
        (import ../lib { inherit (prev) lib; })
      );

      stable = import inputs.stable {
        inherit system;
        config = prev.config;
      };

      gaming = flake.inputs.nix-gaming.packages.${system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = prev.arandr.overrideAttrs (_: { src = inputs.arandr; });

      archivers = prev.callPackage ../packages/archivers { };

      change-res = prev.writeShellApplication {
        name = "change-res";
        runtimeInputs = with prev; [ autorandr mons ];
        text = ''
          detected="$(autorandr --detected)"

          if [[ -n "$detected" ]]; then
            autorandr --change || mons -o
          else
            mons -o
          fi

          systemctl --user restart wallpaper.service
        '';
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
    })
  ];
}

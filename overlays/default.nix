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

      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      gaming = flake.inputs.nix-gaming.packages.${system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = with final.unstable; arandr.overrideAttrs (oldAttrs: {
        src = fetchFromGitLab {
          owner = "thiagokokada";
          repo = oldAttrs.pname;
          rev = "5e2eb669ffe76c6894d597acfcd6f1ae964350e1";
          sha256 = "sha256-sH5D/a92fmPYSyiEYVIipyfFIX0Wgq5MjV1hnG3EHKs=";
        };
      });

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

      nixpkgs-review =
        if (prev.stdenv.isLinux) then
          final.unstable.nixpkgs-review.override { withSandboxSupport = true; }
        else
          final.unstable.nixpkgs-review;

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
    })
  ];
}

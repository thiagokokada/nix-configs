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
      arandr = prev.arandr.overrideAttrs (oldAttrs: {
        patchPhase = ''
          runHook prePatch

          # Not sure why `patches` attribute is not working
          # I am assuming it is because upstream overwrote this phase
          # https://github.com/NixOS/nixpkgs/blob/e6d5267332e2206d6fb2866d7d9b91bfe41f2748/pkgs/tools/X11/arandr/default.nix#L19-L21
          for p in $patches; do
            patch -p1 < $p
          done

          ${oldAttrs.patchPhase or ""}

          runHook postPatch
        '';
        patches = (oldAttrs.patches or [ ]) ++ [
          (prev.fetchpatch {
            name = "MR4_add_support_for_setting_refresh_rate.patch";
            url = "https://gitlab.com/arandr/arandr/-/commit/f2e9f064ccbd08dd74820c7c790f022901f2f78f.patch";
            sha256 = "sha256-dmAM5+I+p+48IKezO/a1Ij57v2HmvPhXbNyanD6Z1FU=";
          })
        ];
      });

      archivers = prev.callPackage ../packages/archivers { };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      nixpkgs-review =
        if (prev.stdenv.isLinux) then
          final.unstable.nixpkgs-review.override { withSandboxSupport = true; }
        else
          final.unstable.nixpkgs-review;

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
    })
  ];
}

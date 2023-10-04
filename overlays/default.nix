{ pkgs, flake, ... }:

{
  nixpkgs.overlays = [
    flake.inputs.emacs.overlay

    (final: prev: {
      # namespaces
      lib = prev.lib.extend (finalLib: prevLib:
        (import ../lib { lib = finalLib; })
      );

      gaming = flake.inputs.nix-gaming.packages.${pkgs.system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = prev.arandr.overrideAttrs (_: { src = flake.inputs.arandr; });

      anime4k = prev.callPackage ../packages/anime4k { };

      change-res = prev.callPackage ../packages/change-res { };

      home-manager = flake.inputs.home.packages.${pkgs.system}.home-manager;

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup {
        isNixOS = true;
      };

      nix-hash-fetchurl = (prev.writeShellScriptBin "nix-hash-fetchurl" ''
        nix-build -E "with import <nixpkgs> {}; fetchurl {url = \"$1\"; sha256 = lib.fakeSha256; }"
      '');

      nix-hash-fetchzip = (prev.writeShellScriptBin "nix-hash-fetchzip" ''
        nix-build -E "with import <nixpkgs> {}; fetchzip {url = \"$1\"; sha256 = lib.fakeSha256; }"
      '');

      # https://github.com/NixOS/nixpkgs/issues/97855#issuecomment-1075818028
      nixos-option =
        let
          prefix = ''
            (import ${flake.inputs.flake-compat} {
              src = ${flake};
            }).defaultNix.nixosConfigurations.\$(hostname)
          '';
        in
        prev.runCommand "nixos-option" { buildInputs = with prev; [ makeWrapper installShellFiles ]; } ''
          makeWrapper ${prev.nixos-option}/bin/nixos-option $out/bin/nixos-option \
            --add-flags --config_expr \
            --add-flags "\"${prefix}.config\"" \
            --add-flags --options_expr \
            --add-flags "\"${prefix}.options\""

          installManPage ${prev.nixos-option}/share/man/**/*
        '';

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

      swaylock-effects = prev.swaylock-effects.overrideAttrs (_: { src = flake.inputs.swaylock-effects; });
    })
  ];
}

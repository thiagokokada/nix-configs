{ flake }:
final: prev:

(flake.inputs.nixgl.overlays.default final prev) //
{
  # namespaces
  libEx = prev.lib.extend (finalLib: prevLib:
    (import ../lib { lib = finalLib; pkgs = final; })
  );

  gaming = flake.inputs.nix-gaming.packages.${prev.system};

  wallpapers = prev.callPackage ../packages/wallpapers { };

  # custom packages
  arandr = prev.arandr.overrideAttrs (_: { src = flake.inputs.arandr; });

  anime4k = prev.callPackage ../packages/anime4k { };

  change-res = prev.callPackage ../packages/change-res { };

  inherit (flake.inputs.home-manager.packages.${prev.system}) home-manager;

  open-browser = prev.callPackage ../packages/open-browser { };

  nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

  nixos-cleanup = prev.callPackage ../packages/nix-cleanup {
    isNixOS = true;
  };

  nix-whereis = prev.callPackage ../packages/nix-whereis { };

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

  inherit (flake.inputs.twenty-twenty-twenty.packages.${prev.system}) twenty-twenty-twenty;

  wl-clipboard-rs = prev.callPackage ../packages/wl-clipboard-rs { };
}

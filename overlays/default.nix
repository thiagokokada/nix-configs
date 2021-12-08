{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      nix-cage = prev.callPackage inputs.nix-cage { };

      nixpkgs-review-cage = pkgs.writeShellScriptBin "nixpkgs-review!" ''
        set -euo pipefail

        nixpkgs="''${NIXPKGS_PATH:-$HOME/Projects/nixpkgs}"
        tmpdir="$(${final.coreutils}/bin/mktemp -d)"
        clean_up() {
          popd >/dev/null
          ${final.coreutils}/bin/rm -rf "$tmpdir"
        }

        pushd "$tmpdir" >/dev/null
        trap "clean_up" EXIT

        ${final.coreutils}/bin/cat <<EOF > shell.nix
        { pkgs ? import <nixpkgs> { }, ... }:

        pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-review ];
        }
        EOF

        pushd "$nixpkgs" >/dev/null

        ${final.nix-cage}/bin/nix-cage \
          "$nixpkgs":rw \
          "$HOME/.cache/nixpkgs-review":rw \
          "$HOME/.config":ro \
          "$HOME":tmpfs \
          --command "cd "$nixpkgs" && ${final.nixpkgs-review}/bin/nixpkgs-review $*"
      '';
    })
  ];
}

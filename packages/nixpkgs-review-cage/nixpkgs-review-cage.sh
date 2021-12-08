#!/usr/bin/env bash

set -euo pipefail

nixpkgs="${NIXPKGS_PATH:-$PWD}"
tmpdir="$(@coreutils@/bin/mktemp -d)"

clean_up() {
    popd >/dev/null
    @coreutils@/bin/rm -rf "$tmpdir"
}
pushd "$tmpdir" >/dev/null
trap "clean_up" EXIT

@coreutils@/bin/cat <<EOF > shell.nix
{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.mkShell {
  buildInputs = with pkgs; [ nixpkgs-review ];
}
EOF

@nix_cage@/bin/nix-cage \
    "$nixpkgs":rw \
    "$HOME/.cache/nixpkgs-review":rw \
    "$HOME/.config":ro \
    "$HOME":tmpfs \
    "/run":ro \
    --command "cd $nixpkgs && @nixpkgs_review@/bin/nixpkgs-review $*"

#!/usr/bin/env bash

set -euo pipefail

readonly NIXOS=@isNixOS@
OPTIMIZE=0
UNSAFE=0

usage() {
if [[ "$NIXOS" == 1 ]]; then
    echo "Clean-up NixOS's /nix/store."
else
    echo "Clean-up nix's /nix/store."
fi
    echo
    echo "Usage:"
if [[ "$NIXOS" == 1 ]]; then
    echo "nixos-cleanup [--optimize] [--unsafe]"
else
    echo "nix-cleanup [--optimize]"
fi
    echo
    echo "Arguments:"
    echo "  --optimize  Run 'nix-store --optimize' afterwards"
if [[ "$NIXOS" == 1 ]]; then
    echo "  --unsafe    Delete booted-system's GC root. Possibly unsafe."
    echo "              Only usable after a 'nixos-rebuild switch'"
fi
    exit 1
}

while [[ "${#:-0}" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --optimize)
            OPTIMIZE=1
            shift
            ;;
        --unsafe)
if [[ "$NIXOS" == 1 ]]; then
            UNSAFE=1
            shift
else
            echo "'$1' is not a recognized flag!"
            exit 1;
fi
            ;;
        *)
            echo "'$1' is not a recognized flag!"
            exit 1;
            ;;
    esac
done

cleanup() {
    find -H /nix/var/nix/gcroots/auto -type l -exec readlink {} \; | \
        grep "/result[-0-9]*$" | \
        xargs -L1 rm -rf
    if [[ "$UNSAFE" == 1 ]]; then
        nix-store --ignore-liveness --delete /nix/var/nix/gcroots/booted-system
    fi
    nix-collect-garbage -d
    if [[ "$NIXOS" == 1 ]]; then
        nixos-rebuild boot --fast
    fi
    if [[ "$OPTIMIZE" == 1 ]]; then
        nix-store --optimize
    fi
}

sudo bash -c "$(declare -f cleanup); cleanup"

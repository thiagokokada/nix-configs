#!/usr/bin/env bash

set -euo pipefail

OPTIMIZE=0
UNSAFE=0

usage() {
    echo "Clean-up NixOS's /nix/store."
    echo
    echo "Usage:"
    echo "nixos-cleanup [--optimize] [--unsafe]"
    echo
    echo "Arguments:"
    echo "  --optimize  Run 'nix-store --optimize' afterwards"
    echo "  --unsafe    Delete booted-system's GC root. Possibly unsafe."
    echo "              Only usable after a 'nixos-rebuild switch'"
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
            UNSAFE=1
            shift
            ;;
        *)
            echo "'$1' is not a recognized flag!"
            exit 1;
            ;;
    esac
done

cleanup() {
    find -H /nix/var/nix/gcroots/auto -type l -exec readlink {} \; | \
        grep "/result$" | \
        xargs -L1 rm -rf
    if [[ "$UNSAFE" == 1 ]]; then
        nix-store --ignore-liveness --delete /nix/var/nix/gcroots/booted-system
    fi
    nix-collect-garbage -d
    nixos-rebuild boot --fast
    if [[ "$OPTIMIZE" == 1 ]]; then
        nix-store --optimize
    fi
}

sudo bash -c "$(declare -f cleanup); cleanup"

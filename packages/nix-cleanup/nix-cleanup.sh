#!/usr/bin/env bash

set -euo pipefail

readonly NIXOS=@isNixOS@
AUTO=0
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
    echo "  --auto      Remove auto created gc-roots (e.g.: '/result' symlinks)."
    echo "  --optimize  Run 'nix-store --optimize' afterwards."
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
        --auto)
            AUTO=1
            shift
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
    if [[ "$AUTO" == 1 ]]; then
        find -H /nix/var/nix/gcroots/auto -type l -exec readlink {} \; | \
            grep "/result[-0-9]*$" | \
            xargs -L1 rm -rf
    fi
    if [[ "$UNSAFE" == 1 ]]; then
        nix-store --ignore-liveness --delete /nix/var/nix/gcroots/booted-system
    fi
    nix-store --verify
    nix-collect-garbage -d
    if [[ "$NIXOS" == 1 ]]; then
        nixos-rebuild boot --fast
    fi
    if [[ "$OPTIMIZE" == 1 ]]; then
        nix-store --optimize
    fi
}

if [[ "$NIXOS" == 1 ]]; then
    sudo bash -c "$(declare -f cleanup); cleanup"
else
    cleanup
fi

#!/usr/bin/env bash

set -euo pipefail

readonly NIXOS=@is_nixos@
PATH="@path@:$PATH"
AUTO=0
OPTIMIZE=0
HM_PROFILE=0

usage() {
if [[ "$NIXOS" == 1 ]]; then
    echo "Clean-up NixOS's /nix/store."
else
    echo "Clean-up nix's /nix/store."
fi
    echo
    echo "Usage:"
if [[ "$NIXOS" == 1 ]]; then
    echo "nixos-cleanup [--auto] [--optimize]"
else
    echo "nix-cleanup [--auto] [--optimize]"
fi
    echo
    echo "Arguments:"
    echo "  --hm-profiles  Remove home-manager profiles."
    echo "  --auto         Remove auto created gc-roots (e.g.: '/result' symlinks)."
    echo "  --optimize     Run 'nix-store --optimize' afterwards."
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
        --hm-profiles)
            HM_PROFILE=1
            shift
            ;;
        *)
            echo "'$1' is not a recognized flag!"
            exit 1;
            ;;
    esac
done

cleanup_hm() {
    local -r hm_profile="$1"

    if [[ "$hm_profile" == 1 ]]; then
        echo "[INFO] Clean-up old home-manager generations..."
        home-manager expire-generations '0 days'
    fi
}

cleanup() {
    local -r auto="$1"
    local -r nixos="$2"
    local -r optimize="$3"

    if [[ "$auto" == 1 ]]; then
        echo "[INFO] Removing auto created GC roots..."
        nix-store --gc --print-roots | \
            awk '{ print $1 }' | \
            grep '/result.*$' | \
            xargs -L1 rm -rf || true
    fi

    echo "[INFO] Verifying nix store..."
    nix-store --verify

    echo "[INFO] Running GC..."
    nix-collect-garbage -d
    if [[ "$nixos" == 1 ]]; then
        echo "[INFO] Rebuilding NixOS to remove old boot entries..."
        if [[ -f /etc/nixos/flake.nix ]]; then
            nixos-rebuild boot
        else
            nixos-rebuild boot --flake github:thiagokokada/nix-configs
        fi
    fi
    if [[ "$optimize" == 1 ]]; then
        echo "[INFO] Optimizing nix store..."
        nix-store --optimize
    fi
}

cleanup_hm "$HM_PROFILE"
if [[ "$NIXOS" == 1 ]]; then
    sudo bash -c "$(declare -f cleanup); cleanup $AUTO $NIXOS $OPTIMIZE"
else
    cleanup "$AUTO" "$NIXOS" "$OPTIMIZE"
fi

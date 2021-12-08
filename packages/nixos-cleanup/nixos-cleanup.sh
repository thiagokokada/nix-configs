#!/usr/bin/env bash

set -euo pipefail

# sudo needs to be the one running on the current system
# also use nix/nixos-rebuild from the current system
sudo -s -- <<EOF
@findutils@/bin/find -H /nix/var/nix/gcroots/auto -type l | \
    @findutils@/bin/xargs readlink | \
    @gnugrep@/bin/grep "/result$" | \
    @findutils@/bin/xargs rm -f
nix-collect-garbage -d
nixos-rebuild boot --fast
if [[ "${1:-}" == "--optimize" ]]; then
    nix-store --optimize
fi
EOF

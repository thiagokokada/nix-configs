#!/usr/bin/env bash

set -euo pipefail

readonly program_name="${1:-}"

if [[ -z "$program_name" ]]; then
    @coreutils@/bin/cat <<EOF
usage: $(@coreutils@/bin/basename "$0") <name>

Locate where in /nix/store a binary is stored.
EOF
    exit 1
fi

@coreutils@/bin/readlink -f "$(@which@/bin/which "$program_name")"

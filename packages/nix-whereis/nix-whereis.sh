#!/usr/bin/env bash

set -euo pipefail

readonly program_name="${1:-}"

if [[ -z "$program_name" ]]; then
   cat <<EOF
usage: $(basename "$0") <name>

Get where in /nix/store a program is located.
EOF
    exit 1
fi

readlink -f "$(which "$program_name")"

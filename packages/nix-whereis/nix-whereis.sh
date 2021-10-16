#!@bash@/bin/bash

set -euo pipefail

readonly program_name="${1:-}"

if [[ -z "$program_name" ]]; then
    echo "usage: $(@coreutils@/bin/basename "$0") PROGRAM"
    exit 1
fi

@coreutils@/bin/readlink -f "$(@which@/bin/which "$program_name")"

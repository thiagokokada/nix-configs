set -euo pipefail

readonly program_name="${1:-}"

if [[ -z "$program_name" ]]; then
    echo "usage: $(basename $0) PROGRAM"
    exit 1
fi

readlink -f "$(which "$program_name")"

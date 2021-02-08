#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl yq jq

# Takes a raw link to the base16 YAML file and converts it to JSON
# Example:
# $ ./get-base16-theme.sh https://raw.githubusercontent.com/chriskempson/base16-tomorrow-scheme/master/tomorrow-night.yaml

curl -s "$1" | \
    yq 'to_entries[] | select(.key | startswith("base")) | .value |= "#" + .' | \
    jq -s 'from_entries'

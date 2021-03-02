#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixpkgs-fmt

nixpkgs-fmt **/*.nix

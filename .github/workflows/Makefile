#! /usr/bin/env nix-shell
#! nix-shell -i "make -f" -p yj nixUnstable

all: build-and-cache.yml update-flakes.yml update-flakes-darwin.yml

%.yml: src/%.nix src/steps.nix src/constants.nix
	nix eval -f $< --json | yj -jy > $@

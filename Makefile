#! /usr/bin/env nix-shell
#! nix-shell shell.nix -i "make -f"

.PHONY: all gh-actions clean update format format-check install activate run-vm-% build-% build-vm-% build-hm-% run-vm-%
EXTRA_FLAGS :=
NIX_FLAGS := --experimental-features 'nix-command flakes' $(EXTRA_FLAGS)

ifeq ($(shell uname),Darwin)
all: all-macos
else
all: all-linux
endif

all-linux: build-miku-nixos build-mikudayo-re-nixos build-mirai-vps build-hm-home-linux

all-macos: build-darwin-miku-macos-vm build-hm-home-macos

clean:
	rm -rf result *.qcow2 .github/workflows/*

update:
	nix flake update --commit-lock-file $(NIX_FLAGS)

validate:
	nix flake check . $(NIX_FLAGS)

format-check:
	nix run '.#formatCheck' $(NIX_FLAGS)

format:
	nix run '.#format' $(NIX_FLAGS)

gh-actions:
	nix run '.#githubActions' $(NIX_FLAGS)

build-%:
	nix build '.#nixosConfigurations.$*.config.system.build.toplevel' $(NIX_FLAGS)

build-darwin-%:
	nix build '.#darwinConfigurations.$*.system' $(NIX_FLAGS)

build-vm-%:
	nix build '.#nixosConfigurations.$*.config.system.build.vm' $(NIX_FLAGS)

build-hm-%:
	nix build '.#homeConfigurations.$*.activationPackage' $(NIX_FLAGS)

run-vm-%:
	nix run '.#nixosVMs/$*' $(NIX_FLAGS)

# Local Variables:
# mode: Makefile
# End:

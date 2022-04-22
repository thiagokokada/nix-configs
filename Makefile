#! /usr/bin/env nix-shell
#! nix-shell shell.nix -i "make -f"

.PHONY: all gh-actions clean update format format-check install activate run-vm-% build-% build-vm-% build-hm-% run-vm-%
EXTRA_FLAGS :=
NIX_FLAGS := --experimental-features 'nix-command flakes' $(EXTRA_FLAGS)
PLATFORM := $(shell nix-instantiate --eval -E 'builtins.currentSystem' --json | jq -r)

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
	nix $(NIX_FLAGS) flake update --commit-lock-file

validate:
	nix $(NIX_FLAGS) flake check .

format-check:
	find -name '*.nix' \
		! -name 'hardware-configuration.nix' \
		! -name 'cachix.nix' \
		! -path './modules/home-manager/*' \
		! -path './modules/nixos/*' \
		-exec nixpkgs-fmt --check {} \+

format:
	find -name '*.nix' \
		! -name 'hardware-configuration.nix' \
		! -name 'cachix.nix' \
		! -path './modules/home-manager/*' \
		! -path './modules/nixos/*' \
		-exec nixpkgs-fmt {} \+

.github/workflows/%.yml: actions/build-and-cache.nix
	nix $(NIX_FLAGS) run '.#githubActions.$(PLATFORM).$*' | tee $@

gh-actions: .github/workflows/build-and-cache.yml .github/workflows/update-flakes.yml .github/workflows/update-flakes-darwin.yml

build-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$*.config.system.build.toplevel'

build-darwin-%:
	nix $(NIX_FLAGS) build '.#darwinConfigurations.$*.system'

build-vm-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$*.config.system.build.vm'

build-hm-%:
	nix $(NIX_FLAGS) build '.#homeConfigurations.$*.activationPackage'

run-vm-%: build-vm-%
	QEMU_OPTS="-cpu host -smp 2 -m 4096M -machine type=q35,accel=kvm" ./result/bin/run-$*-vm

# Local Variables:
# mode: Makefile
# End:

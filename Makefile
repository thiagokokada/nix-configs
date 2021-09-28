#! /usr/bin/env nix-shell
#! nix-shell -I "nixpkgs=channel:nixpkgs-unstable" -i "make -f" -p gnumake nixUnstable findutils nixpkgs-fmt

.PHONY: all clean update format format-check install activate run-vm-% build-% build-vm-% build-hm-% run-vm-%
NIX_FLAGS := --experimental-features 'nix-command flakes'

all: build-miku-nixos build-mikudayo-nixos build-mirai-vps build-hm-home-linux

clean:
	rm -rf result *.qcow2

update:
	nix $(NIX_FLAGS) flake update --commit-lock-file

format-check:
	find -name '*.nix' ! -name 'hardware-configuration.nix' ! -name 'cachix.nix' -exec nixpkgs-fmt --check {} \+

format:
	find -name '*.nix' ! -name 'hardware-configuration.nix' ! -name 'cachix.nix' -exec nixpkgs-fmt {} \+

install:
ifeq (,$(wildcard ./result/nixos-version))
	@>&2 echo "Nothing to install. Run 'make build-<hostname>' first!"
	@exit 1
endif
	nixos-install --system ./result

activate:
ifeq (,$(wildcard ./result/activate))
	@>&2 echo "Nothing to activate. Run 'make build-<hostname>' or 'make build-hm-<name>' first!"
	@exit 1
endif
	./result/activate

build-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$*.config.system.build.toplevel'

build-vm-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$*.config.system.build.vm'

build-hm-%:
	nix $(NIX_FLAGS) build '.#homeConfigurations.$*.activationPackage'

run-vm-%: build-vm-%
	QEMU_OPTS="-cpu host -smp 2 -m 4096M -machine type=q35,accel=kvm" ./result/bin/run-$*-vm

# Local Variables:
# mode: Makefile
# End:

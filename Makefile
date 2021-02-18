#! /usr/bin/env nix-shell
#! nix-shell -i "make -f" -p gnumake nixFlakes

.PHONY: clean activate-home build-vm-miku-nixos build-vm-mikudayo-nixos build-home update
NIX_FLAGS := --experimental-features 'nix-command flakes'

all: build-miku-nixos build-mikudayo-nixos build-home

clean:
	rm -rf result *.qcow2

build-miku-nixos:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.miku-nixos.config.system.build.toplevel'

build-mikudayo-nixos:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.mikudayo-nixos.config.system.build.toplevel'

build-home:
	nix $(NIX_FLAGS) build '.#home'

update:
	nix $(NIX_FLAGS) flake update --recreate-lock-file --commit-lock-file

install:
	nixos-install --system ./result

run-vm:
	export QEMU_OPTS="-cpu host -smp 2 -m 4096M -machine type=q35,accel=kvm"
	./result/bin/run-nixos-vm

activate-home: build-home
	./result/activate

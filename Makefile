#! /usr/bin/env nix-shell
#! nix-shell -i "make -f" -p gnumake

.PHONY: clean activate-home build-vm-desktop build-vm-laptop build-home update

all: build-vm-desktop build-vm-laptop build-home

clean:
	rm -rf result *.qcow2

build-vm-desktop:
	nixos-rebuild build-vm --flake '.#desktop'

build-vm-laptop:
	nixos-rebuild build-vm --flake '.#laptop'

build-home:
	nix build '.#home'

update:
	nix flake update --recreate-lock-file --commit-lock-file

run-vm:
	export QEMU_OPTS="-cpu host -smp 2 -m 4096M -machine type=q35,accel=kvm"
	./result/bin/run-nixos-vm

activate-home: build-home
	./result/activate

#! /usr/bin/env nix-shell
#! nix-shell -I "nixpkgs=channel:nixpkgs-unstable" -i "make -f" -p gnumake nixUnstable

.PHONY: all clean update install home-linux
NIX_FLAGS := --experimental-features 'nix-command flakes'

all: build-miku-nixos build-mikudayo-nixos build-mirai-vps build-home-linux

clean:
	rm -rf result *.qcow2

update:
	nix $(NIX_FLAGS) flake update --commit-lock-file

install:
	nixos-install --system ./result

home-linux: build-home-linux
	./result/activate

# Those targets are technically .PHONY, but if I set them to .PHONY I can't use %
build-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$(subst build-,,$(@F)).config.system.build.toplevel'

build-vm-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$(subst build-vm-,,$(@F)).config.system.build.vm'

build-home-%:
	nix $(NIX_FLAGS) build '.#homeConfigurations.$(subst build-,,$(@F)).activationPackage'

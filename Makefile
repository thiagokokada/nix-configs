#! /usr/bin/env nix-shell
#! nix-shell -i "make -f" -p gnumake nixFlakes

.PHONY: clean activate-home build-vm-miku-nixos build-vm-mikudayo-nixos build-home update
NIX_FLAGS := --experimental-features 'nix-command flakes'

all: build-vm-miku-nixos build-vm-mikudayo-nixos build-home

clean:
	rm -rf result *.qcow2

result/bin/run-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$(subst run-,,$(@F)).config.system.build.vm'

result/bin/activate:
	nix $(NIX_FLAGS) build '.#home'

build-vm-miku-nixos: result/bin/run-miku-nixos

build-vm-mikudayo-nixos: result/bin/run-mikudayo-nixos

build-vm-mikudayo-nubank: result/bin/run-mikudayo-nubank

build-home: result/bin/activate

update:
	nix $(NIX_FLAGS) flake update --recreate-lock-file --commit-lock-file

install:
	nixos-install --system ./result

activate-home: result/bin/activate
	./result/activate

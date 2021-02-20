#! /usr/bin/env nix-shell
#! nix-shell -i "make -f" -p gnumake nixFlakes

.PHONY: all clean home-linux update update-zsh-plugins
NIX_FLAGS := --experimental-features 'nix-command flakes'

all: build-miku-nixos build-mikudayo-nixos build-mirai-vps build-home-linux

clean:
	rm -rf result *.qcow2

update:
	nix $(NIX_FLAGS) flake update --recreate-lock-file --commit-lock-file

update-zsh-plugins:
	./home-manager/scripts/update-zsh-plugins.py | tee ./home-manager/zsh-plugins.nix

install:
	nixos-install --system ./result

home-linux: build-home-linux
	./result/bin/activate

# Those targets are technically .PHONY, but if I set them to .PHONY I can't use %
build-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$(subst build-,,$(@F)).config.system.build.toplevel'

build-vm-%:
	nix $(NIX_FLAGS) build '.#nixosConfigurations.$(subst build-,,$(@F)).config.system.build.vm'

build-home-%:
	nix $(NIX_FLAGS) build '.#homeConfigurations.$(subst build-,,$(@F)).activationPackage'

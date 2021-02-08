.PHONY: clean activate-home build-vm-desktop build-vm-laptop build-home

all: build-vm-desktop build-vm-laptop build-home

clean:
	rm -rf result *.qcow2

build-vm-desktop:
	nixos-rebuild build-vm --flake '.#desktop'

build-vm-laptop:
	nixos-rebuild build-vm --flake '.#laptop'

build-home:
	nix build '.#home'

activate-home: build-home
	./result/activate

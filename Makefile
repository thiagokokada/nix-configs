.PHONY: clean test

all: test-desktop test-laptop

clean:
	rm -rf result *.qcow2

test-desktop:
	nixos-rebuild build-vm --flake '.#desktop'

test-laptop:
	nixos-rebuild build-vm --flake '.#laptop'

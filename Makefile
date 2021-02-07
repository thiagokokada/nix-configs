.PHONY: test

all: test-desktop test-laptop

test-desktop:
	nixos-rebuild build-vm --flake '.#desktop'

test-laptop:
	nixos-rebuild build-vm --flake '.#laptop'

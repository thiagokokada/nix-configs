.PHONY: test

test:
	nixos-rebuild build-vm --flake '.#desktop'

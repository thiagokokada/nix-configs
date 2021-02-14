# nix-configs

*My Nix{OS} configuration files*

## Overview

* nix configuration for my laptops, desktops and more
* **nix flake**-powered
* guaranteed to be **reproducible**
* all of my **dotfiles**

**Note**: this readme assumes [you have enabled nixUnstable + flakes](https://www.tweag.io/blog/2020-07-31-nixos-flakes/).

## Disclaimer

This config is not based on any previous available Flake-based Nix{OS} config,
instead I choose to develop my own from the available examples and
documentation. Some of the resources and repositories that helped me to
build this config:

- https://www.tweag.io/blog/2020-07-31-nixos-flakes/
- https://nixos.wiki/wiki/Flakes
- https://github.com/bqv/nixrc
- https://github.com/colemickens/nixcfg
- https://github.com/lucasew/nixcfg
- https://github.com/Mic92/dotfiles
- https://github.com/nrdxp/nixflk

I decided to build from scratch to have more understand what is happening. Also,
this repo uses less "magic" than other repositories, preferring a copy-and-paste
approach. This may be less DRY, however it helps understanding what is
happening.

## Dotfiles

This repository also includes my `home-manager` configuration. It is
used to configure home in NixOS systems (using `home-manager` as a NixOS module)
but it should also work in standalone mode.

Most of the configuration files are based on my old (but still supported)
[dotfiles repository](https://github.com/thiagokokada/dotfiles).

## Usage

For now, most of "documentation" is available in this repo's `Makefile`. It
should be called as a script since it will automatically download its
dependencies using `nix-shell`.

For example, to build `miku-nixos` configuration run:

```sh
$ ./Makefile build-miku-nixos
```

## Interesting Tidbits

* Everything builds in Nix, with Flakes (meaning Pure mode).
* Specially in Home-Manager, configuration between different components are
shared, so for example changing the color from i3/sway/rofi/dunst/kitty/etc are
all done changing just one file (see
[get-base-16-theme.sh](https://github.com/thiagokokada/nix-configs/blob/master/home-manager/scripts/get-base16-theme.sh)
script for example).

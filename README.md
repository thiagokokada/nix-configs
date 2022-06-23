# nix-configs

[![build-and-cache](https://github.com/thiagokokada/nix-configs/actions/workflows/build-and-cache.yml/badge.svg)](https://github.com/thiagokokada/nix-configs/actions/workflows/build-and-cache.yml)

*My Nix{OS} configuration files*

## Overview

* nix configuration for my laptops, desktops and more
* **nix flake**-powered
* guaranteed to be **reproducible**

## Disclaimer

This config is not based on any previous available Flake-based Nix{OS} config,
instead I choose to develop my own from the available examples and
documentation. Some of the repositories that helped me to build this config:

- https://github.com/bqv/nixrc
- https://github.com/colemickens/nixcfg
- https://github.com/hlissner/dotfiles
- https://github.com/lucasew/nixcfg
- https://github.com/Mic92/dotfiles
- https://github.com/nrdxp/nixflk

Also, some extra resources and documentation about Flakes:

- [Flakes in NixOS Wiki](https://nixos.wiki/wiki/Flakes)
- [Nix Flakes blog posts from
  @eldostra](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Nix 2.4/3.0 documentation](https://nixos.org/manual/nix/unstable/)

**Remember**: Flakes is *experimental*, so you shouldn't try this approach
until you have some experience in Nix.

## Dotfiles

This repository also includes my
[`home-manager`](https://github.com/nix-community/home-manager/) configuration.
It is used to configure home in NixOS systems (using `home-manager` as a NixOS
module) but it should also work in standalone mode.

## Installation

### NixOS

After following the instructions in
[manual](https://nixos.org/manual/nixos/stable/#sec-installation) to prepare the
system and partition the disk, run the following process to install:

```console
$ sudo git clone https://github.com/thiagokokada/nix-configs/ /mnt/etc/nixos
$ sudo chown -R 1000:1000 /mnt/etc/nixos # optional if you want to edit your config without root
$ nix-shell -p nixFlakes
$ nix flake new --template '.#new-host' # if this is a new hardware
$ sudo nixos-install --flake /mnt/etc/nixos#hostname
```

To speed-up the initial setup, you can comment parts of the configuration.
A good start would be to import only `hardware-configuration.nix`,
`nixos/minimal.nix` and `home-manager/minimal.nix`.

After installing it succesfully and rebooting, you can uncomment everything and
trigger a rebuild.

### nix-darwin

Start by installing Nix:

```console
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

See more details
[here](https://nixos.org/manual/nix/stable/#sect-multi-user-installation).

You first need to run nix-darwin
[installer](https://github.com/LnL7/nix-darwin#install):

```console
$ nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
$ ./result/bin/darwin-installer
```

Afterwards run:

```console
$ ./Makefile build-darwin-<hostname>
$ ./result/sw/bin/darwin-rebuild switch --flake .
```

### Home Manager (standalone)

Start by installing Nix:

```console
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

To build the Home Manager standalone and activate its configuration, run:

```console
$ ./Makefile build-hm-<config>
$ ./result/activate
```

## Testing

You can build a VM to test configurations with safety using the available
`Makefile`. It should be called as a script since it will automatically download
its dependencies using `nix-shell`.

For example, to build and run `miku-nixos` configuration inside a VM run:

```console
$ ./Makefile run-vm-miku-nixos
```

## Interesting Tidbits

* Everything builds in Nix, with Flakes (meaning Pure mode).
* Specially in Home-Manager, configuration between different components are
shared, so for example changing the color from i3/sway/rofi/dunst/kitty/etc are
all done changing just one file (see
[get-base-16-colors.sh](https://github.com/thiagokokada/nix-configs/blob/master/home-manager/scripts/get-base16-colors.sh)
script for example).

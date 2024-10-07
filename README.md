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
- https://github.com/Mic92/dotfiles
- https://github.com/nrdxp/nixflk

Also, some extra resources and documentation about Flakes:

- [Flakes in NixOS Wiki](https://nixos.wiki/wiki/Flakes)
- [Nix Flakes blog posts from
  @eldostra](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Nix documentation](https://nixos.org/manual/nix/unstable/)

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
$ sudo chown -R 1000:100 /mnt/etc/nixos # optional if you want to edit your config without root
$ nix flake new --template '.#new-host' # if this is a new hardware
$ sudo nixos-install --flake /mnt/etc/nixos#hostname
```

After installing it succesfully and rebooting, you can uncomment everything and
trigger a rebuild.

#### Remote installations

You can also do remote installations by using `--target-host` flag in
`nixos-rebuild` (from any machine that already has NixOS installed):

```console
$ nixos-rebuild switch --flake '.#hostname' --target-host root@hostname --use-substitutes
```

Or if you don't have `root` access via SSH (keep in kind that the user needs to
have `sudo` permissions instead):

```console
$ nixos-rebuild switch --flake '.#hostname' --target-host user@hostname --use-substitutes --use-remote-sudo
```

Another option for a few hosts is to use
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere). This need to
be a host with [disko](https://github.com/nix-community/disko/) configured. In
this case, you can just run:

```
$ nix run github:numtide/nixos-anywhere -- --flake '.#hostname' root@hostname
```

### nix-darwin

Start by installing Nix:

```console
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

To build the Home Manager standalone and activate its configuration, run:

```console
$ nix run '.#darwinActivations/<hostname>'
```

### Home Manager (standalone)

Start by installing Nix:

```console
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

To build the Home Manager standalone and activate its configuration, run:

```console
$ nix run '.#homeActivations/<hostname>'
```

## Testing

You can build a VM to test NixOS configurations with safety running the
command below:

```console
$ nix run '.#nixosVMs/<hostname>'
```

## Explore

You can explore all outputs from this configuration by using:

``` console
$ nix flake show
```

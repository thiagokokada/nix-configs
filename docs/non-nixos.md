# Non-NixOS setup

List of configuration that needs to be done manually in non-NixOS systems.

## Nix config

In `/etc/nix/nix.conf` file:

```
build-users-group = nixbld
experimental-features = nix-command flakes auto-allocate-uids configurable-impure-env
trusted-users = @sudo # or @wheel
builders-use-substitutes = true
```

## (Optional) Setup remote builders

[See](https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html)
for more information about what remote builders are.

To setup it:

```console
$ nix eval --raw .#nixosConfigurations.sankyuu-nixos.config.environment.etc."nix/machines".text | sudo tee -a /etc/nix/machines
```

This will populate `/etc/nix/machines` file.

Needs Tailscale configured. If for some reason you can't use MagicDNS, you need
to replace the names with the Tailscale IPs.

You also may need to do:

```console
# nix store info --store ssh-ng://zatsune-nixos-uk
The authenticity of host 'zatsune-nixos-uk (100.103.30.119)' can't be established.
ED25519 key fingerprint is SHA256:MGRSSdbNCipNa+4LmdHhq7F7xQMuEX+sJDFqcQq3qgs.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'zatsune-nixos-uk' (ED25519) to the list of known hosts.
Version: 2.18.1
Trusted: 1
```

As `root`, because you need to trust the host certificates in the same user
that the `nix-daemon` is running.

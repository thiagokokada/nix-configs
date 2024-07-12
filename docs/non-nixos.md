# Non-NixOS setup

List of configuration that needs to be done manually in non-NixOS systems.

## Nix config

In `/etc/nix/nix.conf` file:

```
build-users-group = nixbld
experimental-features = nix-command flakes
trusted-users = [ root @sudo ] # or @wheel/@admin
builders-use-substitutes = true
```

### Restart nix-daemon (macOS)

After changing the `/etc/nix/nix.conf` file, you will need to restart the
`nix-daemon`:

```
# launchctl kickstart -k system/org.nixos.nix-daemon
```

## (Optional) Setup remote builders

[See](https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html)
for more information about what remote builders are.

To setup it:

```console
$ nix eval --raw .#nixosConfigurations.sankyuu-nixos.config.environment.etc."nix/machines".text | sudo tee -a /etc/nix/machines
```

This will populate `/etc/nix/machines` file.

Needs Tailscale configured. You also may need to do:

```console
# nix store ping --store ssh-ng://100.97.139.21
Store URL: ssh-ng://100.97.139.21
The authenticity of host '100.97.139.21 (100.97.139.21)' can't be established.
ED25519 key fingerprint is SHA256:JLZRJZARsvg2jtUYuS7+sTx8+FcEICsSj3vUKTHh9lM.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '100.97.139.21' (ED25519) to the list of known hosts.
Version: 2.18.4
Trusted: 1
```

As `root`, because you need to trust the host certificates in the same user
that the `nix-daemon` is running.

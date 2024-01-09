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

In `/etc/nix/machines` file:

```
ssh-ng://100.103.30.119 aarch64-linux - 4 1 - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUY5a3NRZkFGWTRSbVRmdUEzTDdTQ1Z0YlpsZ2hodVBWSDAxWTRDbytvOHIgcm9vdEB6YXRzdW5lLW5peG9zCg==
```

Needs Tailscale configured. You also may need to do:

```console
# nix store info --store ssh-ng://100.103.30.119
The authenticity of host '100.103.30.119 (100.103.30.119)' can't be established.
ED25519 key fingerprint is SHA256:MGRSSdbNCipNa+4LmdHhq7F7xQMuEX+sJDFqcQq3qgs.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '100.103.30.119' (ED25519) to the list of known hosts.
Version: 2.18.1
Trusted: 1
```

As `root`, because you need to trust the host certificates in the same user
that the `nix-daemon` is running.

# Ansible setup

This directory contains host-specific Ansible playbooks. Because sometimes Nix
alone is not enough.

## chibi-miku

The `chibi-miku` playbook bootstraps the postmarketOS laptop using `apk` and
systemd.

Enter the Ansible shell:

```console
$ nix develop '.#ansible'
```

Run the playbook checks:

```console
$ ansible-playbook -i ansible/inventory/localhost.yml ansible/playbooks/chibi-miku.yml --syntax-check
$ ansible-playbook -K -i ansible/inventory/localhost.yml ansible/playbooks/chibi-miku.yml --check
```

Apply it:

```console
$ ansible-playbook -K -i ansible/inventory/localhost.yml ansible/playbooks/chibi-miku.yml
```

The `-K` flag asks for the sudo password Ansible needs for `become: true`.

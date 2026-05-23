# Gnome Extensions

This role handles installing the specified Gnome Shell extensions.

## Requirements

The hosts you are targeting should have the following packages:

- gnome-shell
- unzip

## Role Variables

| Variable            | Required | Default | Description                                                                                                                                                                                                                                                      |
| ------------------- | -------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| gnome_extension_ids | &#9989;  | `[]`    | A list of Gnome Shell extension IDs to install.<br><br>The extension ID can be found in the URL on https://extensions.gnome.org/.<br>For example, the TopIcons Plus URL is https://extensions.gnome.org/extension/1031/topicons/ and the extension ID is `1031`. |

## Dependencies

None

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: luizgavalda.gnome_extensions
      vars:
        gnome_extension_ids:
          - 964
          - 770
```

## License

MIT

## Author Information

Luiz Teixeira

This project is a fork for:
  https://github.com/jaredhocutt/ansible-gnome-extensions - Jared Hocutt

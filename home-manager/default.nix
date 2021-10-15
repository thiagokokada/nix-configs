{ super, lib, ... }:

{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./dev
    ./emacs
    ./git.nix
    ./hexchat.nix
    ./htop.nix
    ./i3.nix
    ./kitty.nix
    ./meta
    ./mpv
    ./neovim.nix
    ./nnn.nix
    ./ssh.nix
    ./sway.nix
    ./theme
    ./tmux.nix
    ./vscode
    ./xterm.nix
    ./zsh.nix
    ../modules/device.nix
    ../modules/meta.nix
    ../modules/theme.nix
  ];
}

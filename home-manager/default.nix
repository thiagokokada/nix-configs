{ super, lib, ... }:

{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./dev.nix
    ./emacs.nix
    ./git.nix
    ./hexchat.nix
    ./htop.nix
    ./i3.nix
    ./kitty.nix
    ./meta.nix
    ./mpv
    ./neovim.nix
    ./nnn.nix
    ./ssh.nix
    ./sway.nix
    ./theme
    ./tmux.nix
    ./zsh.nix
    ../modules/device.nix
    ../modules/meta.nix
    ../modules/theme.nix
  ];
}

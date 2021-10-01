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
    ./misc.nix
    ./mpv.nix
    ./neovim.nix
    ./nnn.nix
    ./ssh.nix
    ./sway.nix
    ./theme.nix
    ./tmux.nix
    ./zsh.nix
    ../modules/device.nix
    ../modules/meta.nix
    ../modules/theme.nix
  ];
}

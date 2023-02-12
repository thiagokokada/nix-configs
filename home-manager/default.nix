{ ... }:

{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./emacs
    ./git.nix
    ./hexchat.nix
    ./htop.nix
    ./i3
    ./kitty.nix
    ./meta
    ./mpv
    ./neovim.nix
    ./nnn.nix
    ./non-nix.nix
    ./ssh.nix
    ./sway
    ./theme
    ./tmux.nix
    ./vscode
    ./xterm.nix
    ./zsh.nix
  ];

  systemd.user.startServices = "sd-switch";
}

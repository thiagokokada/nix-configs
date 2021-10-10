{ ... }:

{
  # Minimal set of packages to have a good CLI experience
  # Good starting point to start porting HM for new systems
  imports = [
    ./cli.nix
    ./git.nix
    ./htop.nix
    ./meta
    ./neovim.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];
}

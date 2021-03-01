{ lib, super, ... }:

with lib; {
  imports = [
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
    ../modules/theme.nix
  ];

  # Inherit device config from NixOS or homeConfigurations
  device = super.device;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}

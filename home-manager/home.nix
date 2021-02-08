{ inputs, system, ... }:

{
  # Allow Home-Manager to access some inputs from Flakes
  _module.args = {
    inherit inputs system;
  };

  imports = [
    ./git.nix
    ./htop.nix
    ./kitty.nix
    ./neovim.nix
    ./nnn.nix
    ./ssh.nix
    ./theme.nix
    ../modules/theme.nix
  ];

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

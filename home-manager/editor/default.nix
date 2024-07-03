{ lib, ... }:

{
  imports = [
    ./emacs
    ./helix.nix
    ./jetbrains.nix
    ./neovim.nix
  ];

  options.home-manager.editor.enable = lib.mkEnableOption "editor config" // {
    default = true;
  };
}

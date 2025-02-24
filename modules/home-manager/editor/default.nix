{ lib, ... }:

{
  imports = [
    ./emacs
    ./helix.nix
    ./idea.nix
    ./neovim.nix
  ];

  options.home-manager.editor.enable = lib.mkEnableOption "editor config" // {
    default = true;
  };
}

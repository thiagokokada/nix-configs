{ lib, ... }:

{
  imports = [
    ./emacs
    ./helix.nix
    ./neovim.nix
    ./vscode
  ];

  options.home-manager.editor.enable = lib.mkDefaultOption "editor config";
}

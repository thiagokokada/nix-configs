{ lib, ... }:

{
  imports = [
    ./emacs
    ./helix.nix
    ./jetbrains.nix
    ./neovim.nix
    ./vscode
  ];

  options.home-manager.editor.enable = lib.mkDefaultOption "editor config";
}

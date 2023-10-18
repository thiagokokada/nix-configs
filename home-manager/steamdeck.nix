{ pkgs, ... }:

{
  imports = [
    ./default.nix
  ];

  home-manager.editor.emacs.enable = true;

  home.packages = with pkgs; [
    wl-clipboard
    xclip
  ];
}

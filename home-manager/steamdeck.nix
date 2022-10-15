{ pkgs, ... }:

{
  imports = [
    ./emacs
    ./minimal.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
    xclip
  ];
}

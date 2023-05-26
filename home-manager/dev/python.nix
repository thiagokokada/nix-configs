{ pkgs, ... }:

{
  home.packages = with pkgs; [
    black
    pyright
    python3
  ];
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gcc
    gnumake
    nim
  ];
}

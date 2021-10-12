{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gnumake
    nim
  ];
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gcc
    nim
    pandoc
    shellcheck
  ];
}

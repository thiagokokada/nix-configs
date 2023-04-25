{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gcc
    nil
    nim
    pandoc
    shellcheck
  ];
}

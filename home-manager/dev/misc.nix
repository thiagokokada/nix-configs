{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gcc
    nim
    pandoc
    rnix-lsp
    shellcheck
  ];
}

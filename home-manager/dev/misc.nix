{ pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    expect
    gcc
    nim
    pandoc
    shellcheck
    unstable.rnix-lsp
  ];
}

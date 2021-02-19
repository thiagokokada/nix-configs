{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    elixir
    erlang
    exa
    expect
    gnumake
    go
    nim
    nix-update
    nixfmt
    nixpkgs-fmt
    nixpkgs-review
    python3Full
    rustup
    sloccount
  ];
}

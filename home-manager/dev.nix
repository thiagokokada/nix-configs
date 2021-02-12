{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    elixir
    erlang
    expect
    gnumake
    go
    nim
    nix-update
    nixpkgs-fmt
    nixpkgs-review
    python3Full
    rustup
    shellcheck
    sloccount
  ];
}

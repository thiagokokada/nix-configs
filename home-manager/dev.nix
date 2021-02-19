{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    clojure
    elixir
    erlang
    exa
    expect
    gnumake
    go
    leiningen
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

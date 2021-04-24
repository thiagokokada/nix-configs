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
    hydra-check
    leiningen
    nim
    nix-update
    nixfmt
    nixpkgs-fmt
    nixpkgs-review
    python3Full
    rustup
    sloccount
    unstable.babashka
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "rlwrap bb";
  };
}

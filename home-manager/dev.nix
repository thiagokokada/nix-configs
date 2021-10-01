{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    clojure
    elixir
    expect
    gnumake
    go
    leiningen
    nim
    python3
    rustup
    sloccount
    unstable.babashka
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "rlwrap bb";
  };
}

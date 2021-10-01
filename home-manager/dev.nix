{ config, lib, pkgs, ... }:

let
  babashka = pkgs.unstable.babashka;
in {
  home.packages = with pkgs; [
    babashka
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
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "${pkgs.rlwrap}/bin/rlwrap ${babashka}/bin/bb";
  };
}

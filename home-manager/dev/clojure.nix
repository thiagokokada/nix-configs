{ config, pkgs, lib, ... }:

let
  jdk =
    # TODO: remove this on 21.11 release
    # Already fixed on master: https://github.com/NixOS/nixpkgs/pull/133806
    if pkgs.stdenv.isDarwin then
      pkgs.unstable.jdk
    else
      pkgs.jdk;
  babashka = pkgs.unstable.babashka;
in
{
  programs.java = {
    enable = true;
    package = jdk;
  };

  home.packages = with pkgs; [
    babashka
    (clojure.override { inherit jdk; })
    (leiningen.override { inherit jdk; })
  ];

  # https://github.com/babashka/babashka/issues/257
  programs.zsh.shellAliases = {
    bb = "${pkgs.rlwrap}/bin/rlwrap ${babashka}/bin/bb";
  };
}

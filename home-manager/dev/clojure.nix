{ config, pkgs, lib, ... }:

let
  inherit (pkgs) jdk;
  babashka = pkgs.unstable.babashka;
in
{
  # FIXME: why is this not working on macOS?
  programs.java = lib.mkIf (!pkgs.stdenv.isDarwin) {
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

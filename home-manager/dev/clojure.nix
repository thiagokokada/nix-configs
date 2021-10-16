{ super, config, pkgs, ... }:

let
  jdk = pkgs.jdk11;
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

{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.hexchat ];

  xdg.configFile."hexchat" = {
    source = with pkgs; stdenv.mkDerivation rec {
      name = "hexchat-theme-monokai";
      buildInputs = [ pkgs.unzip ];
      src = builtins.fetchurl {
        url = "https://dl.hexchat.net/themes/Monokai.hct";
        sha256 = "0hdjck7wqnbbxalbf07mhlz421j48x41bvzdv2qbbc5px2anfhdq";
      };
      unpackPhase = "unzip ${src}";
      installPhase = "cp -r . $out";
    };
    recursive = true;
  };
}

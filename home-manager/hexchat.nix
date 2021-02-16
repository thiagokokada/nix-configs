{ config, lib, pkgs, inputs, ... }:

{
  imports = [ "${inputs.home-hexchat}/modules/programs/hexchat.nix" ];

  programs.hexchat = {
    enable = true;
    overwriteConfigFiles = true;
    channels = {
      freenode = {
        autojoin = [ "#nixos" "#home-manager" ];
        servers = [ "chat.freenode.net" "irc.freenode.net" ];
      };
    };

    settings = {
      irc_nick1 = "K0kada";
      irc_nick2 = "k0kada_t";
      irc_user_name = "K0kada";
      dcc_dir = "${config.home.homeDirectory}/Downloads";
    };

    theme = with pkgs; stdenv.mkDerivation rec {
      name = "hexchat-theme-monokai";
      buildInputs = [ pkgs.unzip ];
      src = builtins.fetchurl {
        url = "https://dl.hexchat.net/themes/Monokai.hct";
        sha256 = "0hdjck7wqnbbxalbf07mhlz421j48x41bvzdv2qbbc5px2anfhdq";
      };
      unpackPhase = "unzip ${src}";
      installPhase = "cp -r . $out";
    };
  };
}

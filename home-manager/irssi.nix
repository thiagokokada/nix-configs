{ config, ... }:

let
  nick = "k0kada_t";
in
{
  programs.irssi = {
    enable = true;
    networks = {
      rizon = {
        inherit nick;
        server = {
          address = "irc.rizon.net";
          port = 6697;
          autoConnect = true;
        };
        channels = {
          nibl.autoJoin = true;
          HorribleSubs.autoJoin = true;
        };
      };
    };
    extraConfig = ''
      settings = {
        core = {
          real_name = "${nick}";
          user_name = "${nick}";
          nick = "${nick}";
        };
        "irc/dcc" = {
          dcc_autoget = "yes";
          dcc_autoresume = "yes";
          dcc_download_path = "${config.device.mediaDir}/Other";
          dcc_file_create_mode = "664";
          dcc_mirc_ctcp = "yes";
          dcc_port = "50000 50010";
        };
      };
    '';
  };
}

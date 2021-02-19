{ config, lib, pkgs, ... }:

{
  programs.irssi = {
    enable = true;
    networks = {
      rizon = {
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
          real_name = "HisNameSake";
          user_name = "hisnamesake";
          nick = "hisnamesake";
          alternate_nick = "hisnamesakealt";
        };
        "irc/dcc" = {
          dcc_autoget = "yes";
          dcc_autoresume = "yes";
          dcc_download_path = "/media/Other";
          dcc_file_create_mode = "664";
          dcc_mirc_ctcp = "yes";
          dcc_port = "50000 50010";
        };
      };
    '';
  };
}

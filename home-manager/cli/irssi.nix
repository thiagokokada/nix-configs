{ config, lib, ... }:

let
  cfg = config.home-manager.cli.irssi;
in
{
  options.home-manager.cli.irssi = {
    enable = lib.mkEnableOption "irssi config" // {
      default = config.home-manager.cli.enable;
    };
    dcc = {
      downloadPath = lib.mkOption {
        type = lib.types.path;
        default = "${config.device.media.directory}/Other";
        description = "DCC's download path";
      };
    };
    user = {
      nickName = lib.mkOption {
        type = lib.types.str;
        default = "k0kada_t";
        description = "IRC's nickname";
      };
      realName = lib.mkOption {
        type = lib.types.str;
        default = cfg.user.nickName;
        description = "IRC's real name";
      };
      userName = lib.mkOption {
        type = lib.types.str;
        default = cfg.user.nickName;
        description = "IRC's username";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.irssi = {
      enable = true;
      networks = {
        rizon = {
          nick = cfg.user.nickName;
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
            real_name = "${cfg.user.realName}";
            user_name = "${cfg.user.userName}";
            nick = "${cfg.user.nickName}";
          };
          "irc/dcc" = {
            dcc_autoget = "yes";
            dcc_autoresume = "yes";
            dcc_download_path = "${cfg.dcc.downloadPath}";
            dcc_file_create_mode = "664";
            dcc_mirc_ctcp = "yes";
            dcc_port = "50000 50010";
          };
        };
      '';
    };
  };
}

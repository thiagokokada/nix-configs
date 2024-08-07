{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.device.media) directory;
  inherit (config.mainUser) username;
  cfg = config.nixos.server.samba;
in
{
  options.nixos.server.samba = {
    enable = lib.mkEnableOption "Samba config";
    shares = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Samba shares.";
      default = {
        inherit (config.users.users.${username}) home;
        media = directory;
      };
    };
  };

  config =
    with config.users.users.${username};
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ samba ];

      services = {
        # Enable Samba
        samba = {
          enable = true;
          openFirewall = true;
          extraConfig = with config.networking; ''
            workgroup = WORKGROUP
            local master = yes
            preferred master = yes
            server string = ${hostName}
            netbios name = ${hostName}
            use sendfile = yes
            hosts allow = 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 localhost
            hosts deny = 0.0.0.0/0
            guest account = nobody
            map to guest = bad user
            mangled names = no
            vfs objects = catia
            catia:mappings = 0x22:0xa8,0x2a:0xa4,0x2f:0xf8,0x3a:0xf7,0x3c:0xab,0x3e:0xbb,0x3f:0xbf,0x5c:0xff,0x7c:0xa6,0x20:0xb1
          '';
          shares = lib.mapAttrs (_: path: {
            inherit path;
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = username;
            "force group" = group;
          }) cfg.shares;
        };
      };
    };
}

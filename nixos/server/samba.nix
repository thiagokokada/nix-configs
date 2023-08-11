{ config, pkgs, lib, ... }:

let
  inherit (config.device) mediaDir;
  inherit (config.meta) username;
in
{
  options.nixos.server.samba.enable = lib.mkEnableOption "Samba config";

  config = with config.users.users.${username};
    lib.mkIf config.nixos.server.samba.enable {
      environment.systemPackages = with pkgs; [ samba ];

      services = {
        # Enable Samba
        samba = {
          enable = true;
          package = pkgs.samba;
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
            catia:mappings = 0x22:0xa8,0x2a:0xa4,0x2f:0xf8,0x3a:0xf7,0x3c:0xab,0x3e:0xbb,0x3f:0xbf,0x5c:0xff,0x7c:0xa6
          '';
          shares = {
            home = {
              path = home;
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = username;
              "force group" = group;
            };
            archive = {
              path = mediaDir;
              browseable = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = username;
              "force group" = group;
            };
          };
        };
      };

      networking = {
        # Open ports to Samba
        firewall = {
          allowedTCPPorts = [ 139 445 ];
          allowedUDPPorts = [ 137 138 ];
        };
      };
    };
}

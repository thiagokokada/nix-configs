{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.device.media) directory;
  inherit (config.meta) username;
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
          settings =
            with config.networking;
            {
              global = {
                "workgroup" = "WORKGROUP";
                "local master" = true;
                "preferred master" = true;
                "server string" = hostName;
                "netbios name" = hostName;
                "use sendfile" = true;
                "hosts allow" = lib.concatStringsSep " " [
                  "192.168.0.0/16"
                  "172.16.0.0/12"
                  "10.0.0.0/8"
                  (lib.optionalString config.nixos.server.tailscale.enable "100.64.0.0/10")
                  "localhost"
                ];
                "hosts deny" = "0.0.0.0/0";
                "bind interfaces only" = lib.mkIf config.nixos.server.tailscale.enable false;
                "guest account" = "nobody";
                "map to guest" = "bad user";
                "mangled names" = false;
                "vfs objects" = "catia fruit";
              };
            }
            // (lib.mapAttrs (_: path: {
              inherit path;
              "browseable" = true;
              "read only" = false;
              "guest ok" = false;
              "create mask" = "0644";
              "directory mask" = "0755";
              # Needs to manually add the password for a new user using:
              # smbpasswd -a <username>
              "force user" = username;
              "force group" = group;
            }) cfg.shares);
        };

        # advertise to Windows hosts
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
      };
    };
}

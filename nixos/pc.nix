{ pkgs, config, lib, ... }:
let
  inherit (config.meta) username;
  archive = "/mnt/archive/${username}";
in
with config.users.users.${username}; {
  imports = [
    ./libvirt
    ../modules/device.nix
  ];

  # Increase number of directories that Linux can monitor for Plex
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 262144;
  };

  # Some misc packages
  environment.systemPackages = with pkgs; [
    btrfs-progs
    gnome.simple-scan
    hdparm
    rtorrent
    samba
  ];

  # Enable scanner support
  hardware.sane.enable = true;

  users.users.${username} = { extraGroups = [ "sane" "lp" ]; };

  services = {
    # Enable irqbalance service
    irqbalance.enable = true;

    # Enable printing
    printing = {
      enable = true;
      drivers = with pkgs; [ epson_201207w ];
    };

    # Enable Plex Media Server
    plex = {
      enable = true;
      openFirewall = true;
      group = group;
      package = pkgs.unstable.plex;
    };

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
          path = archive;
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

    # Enable rtorrent
    rtorrent = {
      enable = true;
      downloadDir = "${archive}/Downloads";
      user = username;
      group = group;
      port = 60001;
      openFirewall = true;
      configText = ''
        # Enable the default ratio group.
        ratio.enable=

        # Change the limits, the defaults should be sufficient.
        ratio.min.set=100
        ratio.max.set=300
        ratio.upload.set=500M

        # Watch directory
        schedule2 = watch_directory,5,5,load.start="${home}/Torrents/*.torrent"
        schedule2 = untied_directory,5,5,stop_untied=
      '';
    };
  };

  systemd.services = {
    rtorrent.serviceConfig.Restart = lib.mkForce "always";
    flood = {
      description =
        "A web UI for rTorrent with a Node.js backend and React frontend.";
      after = [ "rtorrent.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = username;
        Group = group;
        Type = "simple";
        Restart = "always";
        ExecStart = "${pkgs.nodePackages.flood}/bin/flood";
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

  systemd.tmpfiles.rules = [
    "d ${archive}/Downloads 0775 ${username} ${group}"
    "d ${archive}/Music 0775 ${username} ${group}"
    "d ${archive}/Photos 0775 ${username} ${group}"
    "d ${archive}/Videos 0775 ${username} ${group}"
  ];
}

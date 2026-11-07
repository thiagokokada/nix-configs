{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.device.media) directory;
  inherit (config.nixos.home) username;
  cfg = config.nixos.server.rtorrent;
  cfgRt = config.services.rtorrent;
in
{
  options.nixos.server.rtorrent = {
    enable = lib.mkEnableOption "rTorrent config";
    ratio = {
      enable = lib.mkEnableOption "ratio control";
      min = lib.mkOption {
        type = lib.types.int;
        description = "Minimum ratio (if size is reached).";
        default = 200;
      };
      max = lib.mkOption {
        description = "Maximum ratio (if size is not reached).";
        type = lib.types.int;
        default = 300;
      };
      size = lib.mkOption {
        description = "Upload size that should be reached.";
        type = lib.types.str;
        default = "500M";
      };
    };
    flood.enable = lib.mkEnableOption "Flood UI" // {
      default = true;
    };
  };

  config =
    with config.users.users.${username};
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ rtorrent ];

      services = {
        flood = {
          inherit (cfg.flood) enable;
          host = "::";
          openFirewall = true;
          extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
        };
        rtorrent = {
          inherit (cfg) enable;
          inherit group;
          downloadDir = "${directory}/Downloads";
          user = username;
          port = 60001;
          openFirewall = true;
          # Workaround until this PR gets to nixos-unstable:
          # https://github.com/NixOS/nixpkgs/pull/583970
          configText = lib.mkForce ''
            #############################################################################
            # A minimal rTorrent configuration that provides the basic features
            # you want to have in addition to the built-in defaults.
            #
            # See https://github.com/rakshasa/rtorrent/wiki/CONFIG-Template
            # for an up-to-date version.
            #############################################################################

            ## Instance layout (base paths)
            method.insert = cfg.basedir,  private|const|string, (cat,"${cfgRt.dataDir}/")
            method.insert = cfg.download, private|const|string, (cat,"${cfgRt.downloadDir}")
            method.insert = cfg.logs,     private|const|string, (cat,(cfg.basedir),"log/")
            method.insert = cfg.logfile,  private|const|string, (cat,(cfg.logs),(system.time),".log")
            method.insert = cfg.session,  private|const|string, (cat,(cfg.basedir),"session/")
            method.insert = cfg.watch,    private|const|string, (cat,(cfg.basedir),"watch/")
            method.insert = cfg.rpcsock,  private|const|string, (cat,"${cfgRt.rpcSocket}")

            ## Create instance directories
            execute.throw = sh, -c, (cat,\
                "mkdir -p \"",(cfg.download),"\" ",\
                "\"",(cfg.logs),"\" ",\
                "\"",(cfg.session),"\" ",\
                "\"",(cfg.watch),"/load\" ",\
                "\"",(cfg.watch),"/start\" ")

            ## Listening port for incoming peer traffic (fixed; you can also randomize it)
            network.listen.port.range.set = ${toString cfgRt.port}-${toString cfgRt.port}
            network.listen.port.random.set = no

            ## Tracker-less torrent and UDP tracker support
            ## (conservative settings for 'private' trackers, change for 'public')
            dht.mode.set = disable
            protocol.pex.set = no
            trackers.use_udp.set = no

            ## Peer settings
            throttle.max_uploads.set = 100
            throttle.max_uploads.global.set = 250

            throttle.min_peers.normal.set = 20
            throttle.max_peers.normal.set = 60
            throttle.min_peers.seed.set = 30
            throttle.max_peers.seed.set = 80
            trackers.numwant.set = 80

            # Select encryption for handshake and connection:
            #
            # protocol.encryption.set = {deny,allow,prefer,require}
            # protocol.encryption.set = handshake_{deny,allow,prefer,require}, stream_{deny,allow,prefer,require}
            #
            #protocol.encryption.set = deny
            #protocol.encryption.set = require
            #protocol.encryption.set = handshake_prefer, stream_deny
            #protocol.encryption.set = handshake_require, stream_prefer
            protocol.encryption.set = handshake_allow, stream_allow

            ## Limits for file handle resources, this is optimized for
            ## an `ulimit` of 1024 (a common default). You MUST leave
            ## a ceiling of handles reserved for rTorrent's internal needs!

            # Deprecated, see: https://github.com/rakshasa/rtorrent/wiki/Socket-Manager-and-Resource-Allocation

            ## Memory resource usage (increase if you have a large number of items loaded,
            ## and/or the available resources to spend)
            pieces.memory.max.set = 1800M
            network.xmlrpc.size_limit.set = 4M

            ## Basic operational settings (no need to change these)
            session.path.set = (cat, (cfg.session))
            directory.default.set = (cat, (cfg.download))
            log.execute = (cat, (cfg.logs), "execute.log")
            #log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
            execute.nothrow = sh, -c, (cat, "echo >", (session.path), "rtorrent.pid", " ", (system.pid))

            ## Other operational settings (check & adapt)
            system.umask.set = 0027
            #session.umask.set = 0027
            system.cwd.set = (cfg.basedir)
            network.http.dns_cache_timeout.set = 25
            schedule = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))
            #pieces.hash.on_completion.set = no
            #view.sort_current = seeding, greater=d.ratio=
            #keys.layout.set = qwerty
            #network.http.capath.set = "/etc/ssl/certs"
            #network.http.ssl_verify_peer.set = 0
            #network.http.ssl_verify_host.set = 0
            #network.rpc.use_xmlrpc.set = true
            #network.rpc.use_jsonrpc.set = true

            ## Some additional values and commands
            method.insert = system.startup_time, value|const, (system.time)
            method.insert = d.data_path, simple,\
                "if=(d.is_multi_file),\
                    (cat, (d.directory), /),\
                    (cat, (d.directory), /, (d.name))"
            method.insert = d.session_file, simple, "cat=(session.path), (d.hash), .torrent"

            ## Watch directories (add more as you like, but use unique schedule names)
            ## Add torrent
            #schedule = watch_load, 11, 10, ((load.verbose, (cat, (cfg.watch), "load/*.torrent")))
            ## Add & download straight away
            #schedule = watch_start, 10, 10, ((load.start_verbose, (cat, (cfg.watch), "start/*.torrent")))

            ## Run the rTorrent process as a daemon in the background
            ## (and control via XMLRPC sockets)
            #system.daemon.set = true
            #network.scgi.open_local = (cat,(session.path),rpc.socket)
            #execute.nothrow = chmod,770,(cat,(session.path),rpc.socket)
            network.scgi.open_local = (cfg.rpcsock)
            schedule = scgi_group,0,0,"execute.nothrow=chown,\":${cfgRt.group}\",(cfg.rpcsock)"
            schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o=\",(cfg.rpcsock)"

            ## Logging:
            ##   Levels = errors events debug_trace
            ##   Groups = connection_* dht_* peer_* rpc_* session_* storage_* torrent_* tracker_*
            print = (cat, "Logging to ", (cfg.logfile))

            log.open_file = "log", (cfg.logfile)

            log.add_output = "errors", "log"
            log.add_output = "events", "log"
            #log.add_output = "tracker_events", "log"
            #log.add_output = "tracker_requests", "log"

            ### END of rtorrent.rc ###

            ${lib.optionalString cfg.ratio.enable ''
              # Enable the default ratio group.
              ratio.enable=

              # Change the limits, the defaults should be sufficient.
              ratio.min.set=${toString cfg.ratio.min}
              ratio.max.set=${toString cfg.ratio.max}
              ratio.upload.set=${cfg.ratio.size}
            ''}

            ${lib.optionalString cfg.flood.enable ''
              method.redirect=load.throw,load.normal
              method.redirect=load.start_throw,load.start
              method.insert=d.down.sequential,value|const,0
              method.insert=d.down.sequential.set,value|const,0
            ''}

            # Watch directory
            schedule = watch_directory,5,5,load.start="${directory}/Torrents/*.torrent"
            schedule = untied_directory,5,5,stop_untied=

            # Disable when diskspace is low
            schedule = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

            # Set umask for download files
            system.umask.set = 0002
          '';
        };
      };

      systemd.services = {
        flood.serviceConfig = {
          SupplementaryGroups = [ group ];
        };
      };

      systemd.tmpfiles.rules = [
        "d ${directory}/Downloads 2775 ${username} ${group}"
        "d ${directory}/Torrents 2775 ${username} ${group}"
      ];
    };
}

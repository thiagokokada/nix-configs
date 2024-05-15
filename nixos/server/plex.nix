{ config, lib, ... }:

let
  inherit (config.mainUser) username;
  inherit (config.device.media) directory;
in
with config.users.users.${username}; {
  options.nixos.server.plex.enable = lib.mkEnableOption "Plex config";

  config = lib.mkIf config.nixos.server.plex.enable {
    # Increase number of directories that Linux can monitor for Plex
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };

    # Enable Plex Media Server
    services.plex = {
      enable = true;
      openFirewall = true;
      inherit group;
    };

    systemd.services.plex.serviceConfig = {
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = false; # hardware acceleration
      PrivateUsers = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };

    systemd.tmpfiles.rules = [
      "d ${directory}/Other 2775 ${username} ${group}"
      "d ${directory}/Music 2775 ${username} ${group}"
      "d ${directory}/Photos 2775 ${username} ${group}"
      "d ${directory}/Videos 2775 ${username} ${group}"
    ];
  };
}

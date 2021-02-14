{ pkgs, ... }:

let
  # Mostly safe to block unless the service is doing something very strange
  safeHardeningFlags = {
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
  };
  strictHardeningFlags = safeHardeningFlags // {
    PrivateDevices = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = true;
  };
  restrictNetworkFlags = { RestrictAddressFamilies = "AF_UNIX"; };
  unrestrictNetworkFlags = { RestrictAddressFamilies = ""; };
in {
  # systemd-analyze --user security
  systemd.user.services = {
    opentabletdriver.serviceConfig = safeHardeningFlags;
  };

  # systemd-analyze security
  systemd.services = {
    flood.serviceConfig = strictHardeningFlags // restrictNetworkFlags // {
      ProtectHome = false;
    };
    rtorrent.serviceConfig = strictHardeningFlags // {
      ProtectHome = "read-only";
    };
    plex.serviceConfig = strictHardeningFlags;
    samba-nmbd.serviceConfig = safeHardeningFlags // unrestrictNetworkFlags;
    samba-smbd.serviceConfig = safeHardeningFlags // unrestrictNetworkFlags;
    samba-winbindd.serviceConfig = safeHardeningFlags // unrestrictNetworkFlags;
    smartd.serviceConfig = strictHardeningFlags // {
      ProtectClock = false;
      PrivateDevices = false;
      PrivateNetwork = true;
    };
  };

  # TODO: Enable usbguard after finding some way to easily manage it
  # services.usbguard = {
  #   enable = true;
  #   presentDevicePolicy = "keep";
  # };
}

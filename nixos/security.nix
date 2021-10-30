{ pkgs, ... }:
let
  # Mostly safe to block unless the service is doing something very strange
  hardenFlags = { overrides ? { } }:
    {
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      SystemCallArchitectures = "native";
    } // overrides;
  # Further hardening that may be applied depending on the case
  PrivateNetwork = true; # Creates a private 'lo' interface
  ProtectHome = true; # Protect /home from access
  ProtectSystem = true; # Protect most of / from access
  RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6"; # Restrict known address families
in
{
  # systemd-analyze --user security
  systemd.user.services = {
    opentabletdriver.serviceConfig = hardenFlags { };
  };

  # systemd-analyze security
  systemd.services = {
    flood.serviceConfig = hardenFlags {
      overrides = { inherit ProtectSystem RestrictAddressFamilies; };
    };
    rtorrent.serviceConfig = hardenFlags {
      overrides = { inherit ProtectSystem RestrictAddressFamilies; };
    };
    plex.serviceConfig = hardenFlags {
      overrides = { RestrictNamespaces = false; };
    };
    samba-nmbd.serviceConfig = hardenFlags { };
    samba-smbd.serviceConfig = hardenFlags { };
    samba-winbindd.serviceConfig = hardenFlags { };
    smartd.serviceConfig = hardenFlags {
      overrides = {
        inherit ProtectHome ProtectSystem PrivateNetwork;
        ProtectClock = false;
        PrivateDevices = false;
      };
    };
  };

  # TODO: Enable usbguard after finding some way to easily manage it
  # services.usbguard = {
  #   enable = true;
  #   presentDevicePolicy = "keep";
  # };
}

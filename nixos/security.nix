{ pkgs, ... }:
let
  # See `man 5 systemd.exec`
  # Mostly safe to block unless the service is doing something very strange
  hardenFlags = overrides@{ ... }:
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
      ProtectProc = "invisible";
      ProtectSystem = "full"; # Makes /boot, /usr and /etc read-only
      ReadOnlyPaths = "/nix"; # Well, this is NixOS
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    } // overrides;
  # Further hardening that may be applied depending on the case
  PrivateNetwork = true; # Creates a private 'lo' interface
  ProtectHome = true; # Protect /home from access
  ProtectSystem = "strict"; # Makes most of / from write read-only
  RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6"; # Restrict known address families
in
{
  # systemd-analyze security
  systemd.services = {
    earlyoom.serviceConfig = hardenFlags {
      inherit PrivateNetwork ProtectHome ProtectSystem;
      PrivateDevices = false;
    };
    flood.serviceConfig = hardenFlags {
      inherit ProtectSystem RestrictAddressFamilies;
    };
    rtorrent.serviceConfig = hardenFlags {
      inherit RestrictAddressFamilies;
    };
    plex.serviceConfig = hardenFlags {
      RestrictNamespaces = false;
    };
    samba-nmbd.serviceConfig = hardenFlags { };
    samba-smbd.serviceConfig = hardenFlags { };
    samba-winbindd.serviceConfig = hardenFlags { };
    smartd.serviceConfig = hardenFlags {
      inherit ProtectHome ProtectSystem PrivateNetwork;
      ProtectClock = false;
      PrivateDevices = false;
    };
  };

  # TODO: Enable usbguard after finding some way to easily manage it
  # services.usbguard = {
  #   enable = true;
  #   presentDevicePolicy = "keep";
  # };
}

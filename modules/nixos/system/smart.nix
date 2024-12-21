{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.system.smart = {
    enable = lib.mkEnableOption "SMART config" // {
      default = config.nixos.system.enable;
    };
  };

  config = lib.mkIf config.nixos.system.smart.enable {
    environment.systemPackages = with pkgs; [
      hdparm
      smartmontools
    ];

    services.smartd.enable = true;

    systemd.services.smartd.serviceConfig = {
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
  };
}

{ config, lib, ... }:

{
  options.device = {
    type = lib.mkOption {
      type = lib.types.enum [ "desktop" "laptop" "server" "vm" ];
      description = "Type of device";
      default = "desktop";
    };
    netDevices = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Available net devices";
      example = [ "eno1" "wlp2s0" ];
      default = [ "eth0" ];
    };
    mountPoints = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Available mount points";
      example = [ "/" "/mnt/backup" ];
      default =
        if (config ? fileSystems) then
          (lib.lists.subtractLists [ "/boot" "/tmp" "/nix" "/bin" "/usr/bin" ]
            (lib.mapAttrsToList (n: _: n) config.fileSystems))
        else
          [ "/" ];
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      description = "Shared media directory";
      example = "/mnt/media";
      default = "/media";
    };
  };
}

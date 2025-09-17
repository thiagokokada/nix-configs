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
  };
}

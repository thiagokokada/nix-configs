{ config, lib, ... }:

{
  options.nixos.desktop.plymouth.enable = lib.mkEnableOption "Plymouth config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.plymouth.enable {
    boot = {
      plymouth.enable = true;

      # Enable "Silent boot"
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}

{ config, lib, pkgs, ... }:

{
  imports = [ ./btrfs.nix ];

  options.nixos.system.enable = lib.mkDefaultOption "system config";

  config = lib.mkIf config.nixos.system.enable {
    environment.systemPackages = with pkgs; [
      hdparm
      smartmontools
    ];

    boot = {
      initrd.systemd.enable = lib.mkDefault true;

      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
        # Reduce swap preference
        "vm.swappiness" = 10;
        # https://fedoraproject.org/wiki/Changes/IncreaseVmMaxMapCount
        # https://pagure.io/fesco/issue/2993#comment-859763
        "vm.max_map_count" = 1048576;
      };

      # Enable NTFS support
      supportedFilesystems = [ "ntfs" ];

      tmp = {
        # Mount /tmp using tmpfs for performance
        useTmpfs = lib.mkDefault true;
        # If not using above, at least clean /tmp on each boot
        cleanOnBoot = lib.mkDefault true;
      };
    };

    # Increase file handler limit
    security.pam.loginLimits = [{
      domain = "*";
      type = "-";
      item = "nofile";
      value = "524288";
    }];

    # Enable firmware-linux-nonfree
    hardware.enableRedistributableFirmware = true;

    nix = {
      gc = {
        automatic = true;
        dates = "3:15";
        options = "--delete-older-than 7d";
      };
      # Reduce disk usage
      daemonIOSchedClass = "idle";
      # Leave nix builds as a background task
      daemonCPUSchedPolicy = "idle";
    };

    services = {
      # Trim SSD weekly
      fstrim = {
        enable = true;
        interval = "weekly";
      };

      # Decrease journal size
      journald.extraConfig = ''
        SystemMaxUse=500M
      '';

      # Suspend when power key is pressed
      logind.extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
      '';

      # Enable smartd for SMART reporting
      smartd.enable = true;
    };

    systemd = {
      # Reduce default service stop timeouts for faster shutdown
      extraConfig = ''
        DefaultTimeoutStopSec=15s
        DefaultTimeoutAbortSec=5s
      '';
      # systemd's out-of-memory daemon
      oomd = {
        enable = lib.mkDefault true;
        enableSystemSlice = true;
        enableUserServices = true;
      };
    };

    # Enable zram to have better memory management
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };
  };
}

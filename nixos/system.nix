{ config, lib, pkgs, ... }:

{
  options.nixos.system.enable = pkgs.lib.mkDefaultOption "system config";

  config = lib.mkIf config.nixos.system.enable {
    boot = {
      initrd.systemd.enable = lib.mkDefault true;

      # Mount /tmp using tmpfs for performance
      tmpOnTmpfs = lib.mkDefault true;

      # If not using above, at least clean /tmp on each boot
      cleanTmpDir = lib.mkDefault true;

      # Enable NTFS support
      supportedFilesystems = [ "ntfs" ];

      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
        # Reduce swap preference
        "vm.swappiness" = 10;
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

    # Reduce disk usage
    nix = {
      gc = {
        automatic = true;
        dates = "3:15";
        options = "--delete-older-than 7d";
      };
      # Leave nix builds as a background task
      daemonIOSchedClass = "idle";
      daemonCPUSchedPolicy = "idle";
    };

    services = {
      btrfs.autoScrub =
        let
          inherit (config.boot) initrd supportedFilesystems;
          inherit (lib) any mkIf;
          btrfsInInitrd = any (fs: fs == "btrfs") initrd.supportedFilesystems;
          btrfsInSystem = any (fs: fs == "btrfs") supportedFilesystems;
          enable = btrfsInInitrd || btrfsInSystem;
        in
        {
          inherit enable;
          interval = "weekly";
        };

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

      # Enable NTP
      timesyncd.enable = lib.mkDefault true;

      # Enable smartd for SMART reporting
      smartd.enable = true;

      # Set I/O scheduler
      # kyber is set for NVMe, since scheduler doesn't make much sense on it
      # bfq for SATA SSDs/HDDs
      udev.extraRules = ''
        # set scheduler for NVMe
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
        # set scheduler for SSD and eMMC
        ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
        # set scheduler for rotating disks
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      '';
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
        enableRootSlice = true;
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

{ config, lib, ... }:

let
  cfg = config.nixos.system;
in
{
  imports = [
    ./cli.nix
    ./btrfs.nix
    ./smart.nix
    ./vm.nix
  ];

  options.nixos.system = {
    enable = lib.mkEnableOption "system config" // {
      default = true;
    };
    motd.enable = lib.mkEnableOption "show message of the day" // {
      default = true;
    };
    pageCompression = {
      enable = lib.mkOption {
        description = "Page compression strategy.";
        type = lib.types.enum [
          "none"
          "zram"
          "zswap"
        ];
        default = "zram";
      };
      algorithm = lib.mkOption {
        description = "Page compression algorithm.";
        type = lib.types.str;
        default = "lz4";
      };
      memoryPercent = lib.mkOption {
        description = "Maximum amount of memory (in percentage) that can be used.";
        type = lib.types.int;
        default = 50;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        systemd.enable = lib.mkDefault true;
        kernelModules = lib.mkIf (cfg.pageCompression.enable == "zswap") [ "z3fold" ];
      };

      kernelParams = lib.mkIf (cfg.pageCompression.enable == "zswap") [
        "zswap.compressor=${cfg.pageCompression.algorithm}"
        "zswap.enabled=1"
        "zswap.max_pool_percent=${toString cfg.pageCompression.memoryPercent}"
        "zswap.zpool=z3fold"
      ];

      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
        # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
        "vm.swappiness" = lib.mkIf (cfg.pageCompression != "none") 180;
        "vm.watermark_boost_factor" = lib.mkIf (cfg.pageCompression != "none") 0;
        "vm.watermark_scale_factor" = lib.mkIf (cfg.pageCompression != "none") 125;
        "vm.page-cluster" = lib.mkIf (cfg.pageCompression != "none") 0;
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

    # Enable firmware-linux-nonfree
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Enable nftables-based firewall
    networking.nftables.enable = lib.mkDefault true;

    # Increase file handler limit
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "nofile";
        value = "524288";
      }
    ];

    services = {
      cron.enable = true;

      # Trim SSD weekly
      fstrim = {
        enable = true;
        interval = "weekly";
      };

      # Decrease journal size
      journald.extraConfig = ''
        SystemMaxUse=500M
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
        enableRootSlice = true;
        enableUserSlices = true;
      };
    };

    # nixos/modules/misc/version.nix
    users.motd = lib.mkIf cfg.motd.enable ''Welcome to '${config.networking.hostName}' running NixOS ${config.system.nixos.version}!'';

    # Enable zram to have better memory management
    zramSwap = lib.mkIf (cfg.pageCompression.enable == "zram") {
      enable = true;
      inherit (cfg.pageCompression) algorithm memoryPercent;
    };
  };
}

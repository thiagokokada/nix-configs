{
  config,
  lib,
  flake,
  ...
}:

let
  cfg = config.nixos.system;
in
{
  imports = [
    ./binfmt.nix
    ./cli.nix
    ./gpu.nix
    ./networkd.nix
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
        default = "zswap";
      };
      algorithm = lib.mkOption {
        description = "Page compression algorithm.";
        type = lib.types.str;
        default = "lzo";
      };
      memoryPercent = lib.mkOption {
        description = "Maximum amount of memory (in percentage) that can be used.";
        type = lib.types.int;
        default = 25;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        systemd.enable = lib.mkDefault true;
      };

      kernelParams = lib.mkIf (cfg.pageCompression.enable == "zswap") [
        "zswap.compressor=${cfg.pageCompression.algorithm}"
        "zswap.enabled=1"
        "zswap.max_pool_percent=${toString cfg.pageCompression.memoryPercent}"
      ];

      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
      }
      // lib.optionalAttrs (cfg.pageCompression.enable == "zram") {
        # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
        "vm.swappiness" = lib.mkIf cfg.zram.enable 180;
        "vm.watermark_boost_factor" = lib.mkIf cfg.zram.enable 0;
        "vm.watermark_scale_factor" = lib.mkIf cfg.zram.enable 125;
        "vm.page-cluster" = lib.mkIf cfg.zram.enable 0;
      };

      # Disable boot editor for security
      loader.systemd-boot.editor = false;

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

    services = {
      cron.enable = true;

      # Trim SSD weekly
      fstrim = {
        enable = true;
        interval = "weekly";
      };
    };

    systemd = {
      # systemd's out-of-memory daemon
      oomd = {
        enableRootSlice = true;
        enableUserSlices = true;
      };
    };

    system = {
      # Enable NixOS auto-upgrade
      autoUpgrade = {
        enable = lib.mkDefault true;
        flake = "github:thiagokokada/nix-configs";
        persistent = true;
        # Enabled by default only in servers
        allowReboot = lib.mkDefault (config.device.type == "server");
        rebootWindow = {
          lower = lib.mkDefault "02:30";
          upper = lib.mkDefault "05:30";
        };
        randomizedDelaySec = lib.mkDefault "30min";
      };
      configurationRevision = flake.rev or "dirty";
    };

    # nixos/modules/misc/version.nix
    users.motd = lib.mkIf cfg.motd.enable ''
      Welcome to '${config.networking.hostName}' running NixOS ${config.system.nixos.version}!
    '';

    # Enable zram to have better memory management
    zramSwap = lib.mkIf (cfg.pageCompression.enable == "zram") {
      enable = true;
      inherit (cfg.pageCompression) algorithm memoryPercent;
    };
  };
}

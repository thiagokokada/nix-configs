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
    showMotd = lib.mkEnableOption "show message of the day" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
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

      # Suspend when power key is pressed
      logind.extraConfig = ''
        HandlePowerKey=suspend-then-hibernate
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
    users.motd = lib.mkIf cfg.showMotd ''Welcome to '${config.networking.hostName}' running NixOS ${config.system.nixos.version}!'';

    # Enable zram to have better memory management
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };
  };
}

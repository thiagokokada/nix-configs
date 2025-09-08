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
    ./btrfs.nix
    ./cli.nix
    ./smart.nix
    ./vm.nix
    ./virtualisation.nix
  ];

  options.nixos.system = {
    enable = lib.mkEnableOption "system config" // {
      default = true;
    };
    motd.enable = lib.mkEnableOption "show message of the day" // {
      default = true;
    };
    zram.enable = lib.mkEnableOption "page compression" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = lib.mkDefault true;

      kernelParams = [ "zswap.enabled=0" ];

      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
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

    # Workaround run0 issue
    # https://github.com/NixOS/nixpkgs/issues/361592
    security.pam.services.systemd-run0 = {
      setEnvironment = true;
      pamMount = false;
    };

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

      zram-generator = {
        inherit (cfg.zram) enable;
        settings.zram0 = {
          zram-size = "min(ram, 8192)";
        };
      };
    };

    systemd = {
      # systemd's out-of-memory daemon
      oomd = {
        enableRootSlice = true;
        enableUserSlices = true;
      };
      settings.Manager = {
        # Reduce default service stop timeouts for faster shutdown
        DefaultTimeoutStopSec = lib.mkDefault "15s";
        DefaultTimeoutAbortSec = lib.mkDefault "5s";
      };
    };

    system.configurationRevision = flake.rev or "dirty";
    system.rebuild.enableNg = true;

    # nixos/modules/misc/version.nix
    users.motd = lib.mkIf cfg.motd.enable ''
      Welcome to '${config.networking.hostName}' running NixOS ${config.system.nixos.version}!
    '';
  };
}

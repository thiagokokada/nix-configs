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
    zram.enable = lib.mkEnableOption "page compression" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = lib.mkDefault true;

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

    services = {
      cron.enable = true;

      # Trim SSD weekly
      fstrim = {
        enable = true;
        interval = "weekly";
      };

      zram-generator = {
        inherit (cfg.zram) enable;
        settings.zram0 = {
          zram-size = lib.mkDefault "min(ram / 2, 4096)";
          compression-algorithm = lib.mkDefault "zstd";
        };
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
        # Not enabled by default for desktop/laptops, see nixos.server
        # allowReboot = true;
      };
      configurationRevision = flake.rev or "dirty";
    };

    # nixos/modules/misc/version.nix
    users.motd = lib.mkIf cfg.motd.enable ''
      Welcome to '${config.networking.hostName}' running NixOS ${config.system.nixos.version}!
    '';
  };
}

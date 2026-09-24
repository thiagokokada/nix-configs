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
    ./limine.nix
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
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernel.sysctl = {
        # Enable Magic keys
        "kernel.sysrq" = 1;
        # https://docs.kernel.org/admin-guide/sysctl/vm.html#swappiness
        "vm.swappiness" = lib.mkDefault 100;
      };

      loader = {
        efi.canTouchEfiVariables = lib.mkDefault true;

        # Disable boot editor for security
        systemd-boot.editor = false;
      };

      # Enable NTFS support
      supportedFilesystems = [ "ntfs" ];

      tmp = {
        # Mount /tmp using tmpfs for performance
        useTmpfs = lib.mkDefault true;
        # If not using above, at least clean /tmp on each boot
        cleanOnBoot = lib.mkDefault true;
      };

      zswap.enable = lib.mkDefault true;
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
  };
}

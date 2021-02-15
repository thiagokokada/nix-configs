{ config, lib, pkgs, ... }:

with config.boot;
with lib;
let
  btrfsInInitrd = any (fs: fs == "btrfs") initrd.supportedFilesystems;
  btrfsInSystem = any (fs: fs == "btrfs") supportedFilesystems;
  enableBtrfs = btrfsInInitrd || btrfsInSystem;

  nixos-clean-up = pkgs.writeShellScriptBin "nixos-clean-up" ''
    set -euo pipefail

    sudo -s -- <<EOF
    find -H /nix/var/nix/gcroots/auto -type l | xargs readlink | grep "/result$" | xargs rm -f
    nix-collect-garbage -d
    nixos-rebuild boot --fast
    if [[ "''${1:-}" == "--optimize" ]]; then
      nix-store --optimize
    fi
    EOF
  '';
in {
  environment.systemPackages = with pkgs; [ cachix nixos-clean-up ];

  nix.trustedUsers = [ "root" "@wheel" ];

  boot = {
    # Mount /tmp using tmpfs for performance
    tmpOnTmpfs = true;

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
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];

  hardware = {
    # Enable CPU microcode for Intel
    cpu.intel.updateMicrocode = true;
  };

  # Reduce disk usage
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    autoOptimiseStore = true;
  };

  # Enable NixOS auto-upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    dates = "Mon,Wed,Fri,Sun 22:00";
    flags = [
      "--recreate-lock-file"
      "--commit-lock-file"
    ];
  };

  services = {
    btrfs.autoScrub = mkIf enableBtrfs {
      enable = true;
      interval = "weekly";
    };

    # Kill process consuming too much memory before it crawls the machine
    earlyoom.enable = true;

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
    timesyncd.enable = true;

    # Set I/O scheduler
    # mq-deadline is set for NVMe, since scheduler doesn't make much sense on it
    # bfq for SATA SSDs/HDDs
    udev.extraRules = ''
      # set scheduler for NVMe
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"
      # set scheduler for SSD and eMMC
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
      # set scheduler for rotating disks
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';
  };

  # Enable zram to have better memory management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}

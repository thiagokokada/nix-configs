{ config, pkgs, lib, ... }:

{
  # Enable unfree packages
  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thiagoko = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "networkmanager" "video" ];
     shell = pkgs.zsh;
     password = "changeme";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

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

  # Change some default locales
  environment.variables = {
    LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
    LC_TIME = "pt_BR.UTF-8";
    LC_COLLATE = "C"; # Use C style string sort.
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
    dates = "daily";
  };

  services = {
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
    # Using mkDefault since it doesn't work in VMs
    timesyncd.enable = lib.mkDefault true;

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

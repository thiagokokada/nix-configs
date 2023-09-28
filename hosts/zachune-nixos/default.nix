# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports = [
    ../../nixos
  ];

  nixos.home.imports = [
    ../../home-manager/minimal.nix
  ];

  device.type = "server";

  nixos = {
    server = {
      iperf3.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
    };
    system.smart.enable = false;
  };

  networking.hostName = "zachune-nixos";

  swapDevices = [
    { device = "/swapfile"; }
  ];

  # Does not support boot.growPartition yet
  boot.initrd.systemd.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";

  # TODO: once this is merged we can just:
  # imports = [ "${modulesPath}/virtualisation/oci-common.nix" ];
  # https://github.com/NixOS/nixpkgs/pull/119856
  boot.kernelParams = [
    "nvme.shutdown_timeout=10"
    "nvme_core.shutdown_timeout=10"
    "libiscsi.debug_libiscsi_eh=1"
    "crash_kexec_post_notifiers"

    # VNC console
    "console=tty1"

    # x86_64-linux
    "console=ttyS0"

    # aarch64-linux
    "console=ttyAMA0,115200"
  ];

  boot.growPartition = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    device = "nodev";
    splashImage = null;
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
    efiInstallAsRemovable = true;
    efiSupport = true;
  };
}

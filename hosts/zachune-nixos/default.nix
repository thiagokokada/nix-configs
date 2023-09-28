# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, ... }:

{
  imports = [
    ../../nixos
    "${modulesPath}/virtualisation/oci-common.nix"
  ];

  nixos.home.imports = [
    ../../home-manager/minimal.nix
  ];

  device.type = "server";

  nixos = {
    server = {
      iperf3.enable = true;
      ssh = {
        enable = true;
        enableRootLogin = true;
      };
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

  # Probably too low memory for it to work well
  systemd.oomd.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
}

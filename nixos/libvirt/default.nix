{ flake, config, pkgs, ... }:
let
  inherit (config.meta) username;

in
{
  imports = [
    ./windows.nix
  ];

  boot = {
    # Do not load NVIDIA drivers
    blacklistedKernelModules = [ "nvidia" "nouveau" ];

    # Load VFIO related modules
    kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    extraModprobeConfig = "options vfio-pci ids=10de:1c02,10de:10f1";

    # Enable IOMMU
    kernelParams = [ "intel_iommu=on" ];
  };

  environment.systemPackages = with pkgs; [ virtmanager ];

  networking = {
    # Needs to disable global DHCP to use bridge interfaces
    useDHCP = false;
    interfaces.br0.useDHCP = true;

    # Enable bridge
    bridges = {
      br0 = {
        interfaces = config.device.netDevices;
      };
    };
  };

  # Enable libvirtd
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf = {
          enable = true;
          packages = with pkgs; [ OVMFFull ];
        };
        swtpm.enable = true;
        runAsRoot = false;
        verbatimConfig = ''
          nographics_allow_host_audio = 1
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc","/dev/hpet",
          ]
        '';
      };
    };
  };

  # Add user to libvirtd group.
  users.users.${username} = { extraGroups = [ "libvirtd" ]; };

  # Enable irqbalance service
  services.irqbalance.enable = true;

  # Reduce latency.
  powerManagement.cpuFreqGovernor = "performance";
}

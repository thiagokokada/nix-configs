{ config, lib, pkgs, ... }:

let
  inherit (config.my) username;
  targetDisk = "/dev/sda";
  reservedGuestCpus = "2-5";
  startVmScript = name:
    pkgs.writeShellScriptBin "start-${name}" ''
      sudo -s -- <<EOF
      # Make sure we have sufficient memory for hugepages
      sync
      echo 3 | tee /proc/sys/vm/drop_caches
      echo 1 | tee /proc/sys/vm/compact_memory

      # Reduce VM jitter: https://www.kernel.org/doc/Documentation/kernel-per-CPU-kthreads.txt
      ${pkgs.procps}/bin/sysctl vm.stat_interval=120
      # the kernel's dirty page writeback mechanism uses kthread workers. They introduce
      # massive arbitrary latencies when doing disk writes on the host and aren't
      # migrated by cset. Restrict the workqueue to use only cpu 0.
      echo 00 | tee /sys/bus/workqueue/devices/writeback/cpumask

      ${pkgs.cpusetWithPatch}/bin/cset shield --reset
      ${pkgs.cpusetWithPatch}/bin/cset shield --cpu "${reservedGuestCpus}" --kthread=on
      ${pkgs.libvirt}/bin/virsh start "${name}"
      EOF
    '';

  stopVmScript = name:
    pkgs.writeShellScriptBin "stop-${name}" ''
      sudo -s -- <<EOF
      ${pkgs.libvirt}/bin/virsh shutdown "${name}"
      # All VMs offline
      echo ff | tee /sys/bus/workqueue/devices/writeback/cpumask
      ${pkgs.procps}/bin/sysctl vm.stat_interval=1
      ${pkgs.cpusetWithPatch}/bin/cset shield --reset
      EOF
    '';

in {
  boot = {
    # Early load i195 for better resolution in init.
    initrd.kernelModules = [ "i915" ];

    # Do not load NVIDIA drivers.
    blacklistedKernelModules = [ "nvidia" "nouveau" "hid-uclogic" ];

    # Load VFIO related modules.
    kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    extraModprobeConfig = "options vfio-pci ids=10de:1c02,10de:10f1";

    # Enable IOMMU
    kernelParams = [ "intel_iommu=on" ];
  };

  environment.systemPackages = with pkgs; [
    (startVmScript "win10")
    (stopVmScript "win10")
    cpusetWithPatch
    virtmanager
  ];

  networking = {
    # Needs to disable global DHCP to use bridge interfaces
    useDHCP = false;
    interfaces.br0.useDHCP = true;

    # Enable bridge
    bridges = {
      br0 = {
        interfaces = if config.networking.usePredictableInterfaceNames then
          [ "eno1" ]
        else
          [ "eth0" ];
      };
    };
  };

  # Enable libvirtd
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuOvmf = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemuVerbatimConfig = ''
        nographics_allow_host_audio = 1
      '';
    };
  };

  # Add user to libvirtd group.
  users.users.${username} = { extraGroups = [ "libvirtd" ]; };

  systemd.services.setup-win10-vm = {
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = ''
      uuid="$(${pkgs.libvirt}/bin/virsh domuuid win10 || true)"
      xml=$(sed -e "s|@UUID@|$uuid|" -e "s|@DISK@|${targetDisk}|" ${./win10.xml})
      ${pkgs.libvirt}/bin/virsh define <(echo "$xml")
    '';
  };

  # Reduce latency.
  powerManagement.cpuFreqGovernor = "performance";
}

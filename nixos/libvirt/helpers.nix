{ pkgs, ... }:

{
  startVmScript = name: allowedCpus:
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

      # https://www.reddit.com/r/VFIO/comments/ebe3l5/deprecated_isolcpus_workaround/fem8jgk?utm_source=share&utm_medium=web2x&context=3
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- user.slice AllowedCPUs=${allowedCpus}
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- system.slice AllowedCPUs=${allowedCpus}
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- init.scope AllowedCPUs=${allowedCpus}
      ${pkgs.libvirt}/bin/virsh start "${name}"
      EOF
    '';

  stopVmScript = name: allCpus:
    pkgs.writeShellScriptBin "stop-${name}" ''
      sudo -s -- <<EOF
      ${pkgs.libvirt}/bin/virsh shutdown "${name}"
      # All VMs offline
      echo ff | tee /sys/bus/workqueue/devices/writeback/cpumask
      ${pkgs.procps}/bin/sysctl vm.stat_interval=1

      # https://www.reddit.com/r/VFIO/comments/ebe3l5/deprecated_isolcpus_workaround/fem8jgk?utm_source=share&utm_medium=web2x&context=3
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- user.slice AllowedCPUs=${allCpus}
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- system.slice AllowedCPUs=${allCpus}
      ${pkgs.systemd}/bin/systemctl set-property --runtime -- init.scope AllowedCPUs=${allCpus}
      EOF
    '';
}

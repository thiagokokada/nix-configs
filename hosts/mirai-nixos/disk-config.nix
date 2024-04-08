{
  disk = {
    vdb = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1M";
            type = "EF02"; # for GRUB MBR
          };
          root = {
            end = "-5G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          plainSwap = {
            size = "100%";
            content = {
              type = "swap";
              resumeDevice = true; # resume from hiberation from this device
            };
          };
        };
      };
    };
  };
}

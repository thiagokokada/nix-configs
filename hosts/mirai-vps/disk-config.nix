{
  disk = {
    vda = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "table";
        format = "msdos";
        partitions = [
          {
            name = "swap";
            start = "1M";
            end = "5G";
            content = {
              type = "swap";
            };
          }
          {
            name = "root";
            start = "5G";
            end = "100%";
            bootable = true;
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
            };
          }
        ];
      };
    };
  };
}

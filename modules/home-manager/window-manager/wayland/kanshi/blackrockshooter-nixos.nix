[
  {
    output.criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
    output.mode = "3440x1440@99.98";
    output.scale = 1.50;
  }
  {
    output.criteria = "LG Electronics LG TV SSCR2 0x01010101";
    output.scale = 2.0;
  }
  {
    profile.name = "tv-only";
    profile.outputs = [
      {
        criteria = "LG Electronics LG TV SSCR2 0x01010101";
        status = "enable";
      }
    ];
  }
  {
    profile.name = "tv-disable";
    profile.outputs = [
      {
        criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
        status = "enable";
      }
      {
        criteria = "LG Electronics LG TV SSCR2 0x01010101";
        status = "disable";
      }
    ];
  }
  {
    profile.name = "monitor-only";
    profile.outputs = [
      {
        criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
        status = "enable";
      }
    ];
  }
]

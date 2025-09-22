[
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
    profile.name = "monitor-only";
    profile.outputs = [
      {
        criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
        mode = "3440x1440@99.98";
        status = "enable";
      }
      {
        criteria = "LG Electronics LG TV SSCR2 0x01010101";
        status = "disable";
      }
    ];
  }
]

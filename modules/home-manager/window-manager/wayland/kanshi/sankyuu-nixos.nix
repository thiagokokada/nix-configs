[
  {
    output.criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
    output.mode = "3440x1440@99.98";
    output.scale = 1.50;
  }
  {
    output.criteria = "eDP-1";
    output.scale = 2.0;
  }
  {
    profile.name = "undocked";
    profile.outputs = [
      {
        criteria = "eDP-1";
        status = "enable";
      }
    ];
  }
  {
    profile.name = "docked";
    profile.outputs = [
      {
        criteria = "Dell Inc. DELL S3423DWC 10CWNH3";
        status = "enable";
      }
      {
        criteria = "eDP-1";
        status = "disable";
      }
    ];
  }
]

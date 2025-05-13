{ ... }:

{
  services.kanshi.settings = [
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
          mode = "3440x1440@99.98";
          status = "enable";
        }
        {
          criteria = "eDP-1";
          status = "disable";
        }
      ];
    }
  ];
}

{ ... }:

{
  services.kanshi.profiles = {
    undocked = {
      exec = [ "systemctl restart --user waybar.service" ];
      outputs = [
        {
          criteria = "eDP-1";
          status = "enable";
        }
      ];
    };
    docked = {
      exec = [ "systemctl restart --user waybar.service" ];
      outputs = [
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
    };
  };
}

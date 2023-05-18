{ pkgs, lib, config, ... }:

let
  interval = 5;
  isLaptop = config.device.type == "laptop";
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [{
      layer = "top";
      position = "top";
      height = 24;
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = lib.filter (m: m != "") [
        "network"
        "disk"
        "memory"
        "cpu"
        "temperature"
        "idle_inhibitor"
        (lib.optionalString isLaptop "backlight")
        (lib.optionalString isLaptop "battery")
        "pulseaudio" # wireplumber is causing segfault
        "clock"
        "tray"
      ];
      idle_inhibitor = {
        format = " {icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      network =
        let
          bandwidthFormat = " {bandwidthUpBytes}  {bandwidthDownBytes}";
        in
        {
          inherit interval;
          format-wifi = " {essid} ({signalStrength}%) ${bandwidthFormat}";
          format-ethernet = " ${bandwidthFormat}";
          format-disconnected = " Disconnected";
        };
      # TODO: support multiple disks
      disk = {
        inherit interval;
        format = " {free}";
        path = "/";
      };
      memory = {
        inherit interval;
        format = " {avail:0.0f}G";
        format-alt = " {swapAvail:0.0f}G";
      };
      cpu = {
        inherit interval;
        format = " {usage}%  {load:0.1f}";
      };
      temperature = {
        format = "{icon} {temperatureC}°C";
        format-icons = [ "" "" "" "" "" ];
        critical-threshold = 80;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = [ "" "" "" ];
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.pamixer}/bin/pamixer --toggle-mute";
        scroll-step = 5;
        max-volume = 150;
        ignored-sinks = [ "Easy Effects Sink" ];
      };
      backlight = {
        format = " {percent}%";
        on-scroll-up = "light -A 5%";
        on-scroll-down = "light -U 5%";
      };
      battery = {
        inherit interval;
        format = "{icon} {capacity}%";
        format-icons = {
          default = [ "" "" "" "" "" ];
          plugged = "";
        };
        states = {
          warning = 20;
          critical = 5;
        };
      };
      clock = {
        inherit interval;
        format = " {:%R}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          "mode" = "year";
          "mode-mon-col" = 3;
          "weeks-pos" = "right";
          "on-scroll" = 1;
          "on-click-right" = "mode";
          "format" = {
            "months" = "<span color='#ffead3'><b>{}</b></span>";
            "days" = "<span color='#ecc6d9'><b>{}</b></span>";
            "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
            "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
            "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
      };
    }];
    style = with config.theme.colors; ''
      * {
         padding: 0 3px;
         border: none;
         border-radius: 0;
         font-family: Roboto, "Font Awesome 6 Free Solid";
       }
       window#waybar {
         background: ${base00};
         color: ${base05};
       }
       #workspaces button {
         padding: 0 5px;
       }
       #workspaces button.focused {
         background: ${base0D};
         color: ${base00};
       }
       #workspaces button.urgent {
         background: ${base08};
         color: ${base00};
       }
       #temperature.critical {
         background: ${base08};
       }
       #pulseaudio.muted {
         background: ${base08};
       }
       #tray > .needs-attention {
         background: ${base08};
       }
       #battery.warning {
         background: ${base08};
       }
       #battery.critical {
         background: ${base0A};
       }
    '';
  };
}

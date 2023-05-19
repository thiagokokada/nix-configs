{ pkgs, lib, config, ... }:

let
  interval = 5;
  isLaptop = config.device.type == "laptop";
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 3;
        modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
        modules-center = [ "sway/window" ];
        modules-right =
          # Add a separator between each module, except the last one
          lib.init (builtins.concatMap (m: [ m "custom/separator" ])
            # Filter optional modules
            (lib.filter (m: m != "") [
              "network"
              "disk"
              "memory"
              "cpu#usage"
              "cpu#load"
              "temperature"
              "custom/dunst"
              "idle_inhibitor"
              (lib.optionalString isLaptop "backlight")
              (lib.optionalString isLaptop "battery")
              "pulseaudio" # wireplumber is causing segfault
              "clock"
              "tray"
            ]));
        "sway/mode".tooltip = false;
        "sway/window".max-length = 50;
        "sway/workspaces".disable-scroll-wraparound = true;
        "wlr/taskbar" = {
          format = "{icon}";
          on-click = "activate";
          on-click-middle = "close";
        };
        idle_inhibitor = {
          format = " {icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          tooltip = false;
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
        "cpu#usage" = {
          inherit interval;
          format = " {usage}%";
        };
        "cpu#load" = {
          inherit interval;
          format = " {load:0.1f}";
        };
        temperature = {
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" "" "" ];
          critical-threshold = 80;
        };
        "custom/dunst" = {
          exec = (pkgs.writeShellApplication {
            name = "dunst-status";
            runtimeInputs = with pkgs; [ dbus dunst gnugrep ];
            text = ''
              COUNT="$(dunstctl count waiting)"
              ENABLED=" ";
              DISABLED=" ";
              if [ "$COUNT" != 0 ]; then
                DISABLED="  ($COUNT)"
              fi
              if dunstctl is-paused | grep -q "false" ; then
                echo "$ENABLED"
              else
                echo "$DISABLED"
              fi
            '';
          }) + "/bin/dunst-status";
          on-click = (pkgs.writeShellApplication {
            name = "dunst-toggle";
            runtimeInputs = with pkgs; [ dbus dunst ];
            text = "dunstctl set-paused toggle";
          }) + "/bin/dunst-toggle";
          restart-interval = interval;
          tooltip = false;
        };
        "custom/separator" = {
          format = "|";
          interval = "once";
          tooltip = false;
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
          on-scroll-up = "${pkgs.light}/bin/light -A 5%";
          on-scroll-down = "${pkgs.light}/bin/light -U 5%";
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
          format = " {:%H:%M, %a %d}";
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
      };
    };
    style = with config.theme.colors; ''
      * {
         border: none;
         border-radius: 0;
         font-family: Roboto, "Font Awesome 6 Free Solid";
       }
       window#waybar {
         background: ${base00};
         color: ${base05};
       }
       #mode {
         background: ${base0A};
         color: ${base00};
         padding: 0 7px;
       }
       #window {
         padding: 0 3px;
       }
       #workspaces button {
         padding: 0 7px;
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
         color: ${base08};
       }
       #pulseaudio.muted {
         color: ${base08};
       }
       #tray > .needs-attention {
         color: ${base08};
       }
       #battery.warning {
         color: ${base0A};
       }
       #battery.critical {
         color: ${base08};
       }
      #custom-separator {
        color: ${base02};
      }
    '';
  };
}

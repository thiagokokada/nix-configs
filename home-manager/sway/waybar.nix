{ pkgs, lib, config, ... }:

let
  interval = 5;
  isLaptop = config.device.type == "laptop";
  shortPath' = with lib.strings;
    (sep: path: concatStringsSep sep (map (substring 0 1) (splitString "/" path)));
  shortPath = shortPath' "/";
  shortPathName = path: "disk#${shortPath' "_" path}";
in
{
  home.packages = with pkgs; [
    font-awesome_6
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

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
            (lib.filter (m: m != "")
              # Flatten maps
              (lib.flatten [
                "network"
                (map (m: shortPathName m) config.device.mountPoints)
                "memory"
                "cpu#usage"
                "temperature"
                "cpu#load"
                "custom/dunst"
                "idle_inhibitor"
                (lib.optionalString isLaptop "backlight")
                (lib.optionalString isLaptop "battery")
                "pulseaudio" # wireplumber is causing segfault
                "clock"
                "tray"
              ])));
        "sway/mode".tooltip = false;
        "sway/window".max-length = 50;
        "sway/workspaces".disable-scroll-wraparound = true;
        "wlr/taskbar" = {
          format = "{icon}";
          on-click = "activate";
          on-click-middle = "close";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            deactivated = "";
            activated = "";
          };
          tooltip = false;
        };
        network =
          let
            bandwidthFormat = " {bandwidthUpBytes}  {bandwidthDownBytes}";
          in
          {
            inherit interval;
            format = "󰈀";
            format-wifi = "{icon} {essid} ${bandwidthFormat}";
            format-ethernet = "󰈀 ${bandwidthFormat}";
            format-disconnected = "󰤮";
            format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          };
      } //
      (lib.recursiveMergeAttrs
        (map
          (m: {
            "${shortPathName m}" = {
              inherit interval;
              format = " ${shortPath m}: {free}";
              path = m;
              states = {
                warning = 75;
                critical = 95;
              };
            };
          })
          config.device.mountPoints))
      // {
        memory = {
          inherit interval;
          format = " {avail:0.0f}G";
          format-alt = " {swapAvail:0.0f}G";
          states = {
            warning = 75;
            critical = 95;
          };
        };
        "cpu#usage" = {
          inherit interval;
          format = "{icon} {max_frequency}GHz";
          format-icons = [ "󰡳" "󰡵" "󰊚" "󰡴" ];
          states = {
            warning = 75;
            critical = 95;
          };
        };
        "cpu#load" = {
          inherit interval;
          format = " {load:0.1f}";
          tooltip = false;
        };
        temperature = {
          format = "{icon} {temperatureC}°C";
          format-icons = [ "" "" "" "" "" ];
          critical-threshold = 75;
        };
        "custom/dunst" = {
          exec = (pkgs.writeShellApplication {
            name = "dunst-status";
            runtimeInputs = with pkgs; [ coreutils dbus dunst procps ];
            text = ''
              # sending SIGKILL here since HUP/TERM are not killing dbus-monitor for some reason
              cleanup() { kill -SIGKILL 0; }

              trap "cleanup" EXIT

              readonly ENABLED=''
              readonly DISABLED=''
              # --profile outputs a single line per message
              dbus-monitor path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged' --profile |
                while read -r _; do
                  PAUSED="$(dunstctl is-paused)"
                  # exit if parent process exit
                  if ! ps -p "$PPID" >/dev/null; then
                    cleanup
                  fi
                  if [ "$PAUSED" == 'false' ]; then
                    CLASS="enabled"
                    TEXT="$ENABLED"
                  else
                    CLASS="disabled"
                    TEXT="$DISABLED"
                    COUNT="$(dunstctl count waiting)"
                    if [ "$COUNT" != '0' ]; then
                      TEXT="$DISABLED ($COUNT)"
                    fi
                  fi
                  printf '{"text": "%s", "class": "%s"}\n' "$TEXT" "$CLASS"
                done
            '';
          }) + "/bin/dunst-status";
          on-click = "${pkgs.dunst}/bin/dunstctl set-paused toggle";
          restart-interval = 1;
          return-type = "json";
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
          states = {
            normal = 100;
            high = 150;
          };
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
            critical = 10;
          };
        };
        clock = {
          inherit interval;
          format = " {:%H:%M, %a %d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };
      };
    };
    style = with config.theme.colors; ''
      * {
        border: none;
        border-radius: 0;
        font-family: Roboto, "Font Awesome 6 Free Solid", "Symbols Nerd Font";
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
      #tray > .needs-attention {
        color: ${base08};
      }
      #battery.warning {
        color: ${base0A};
      }
      #battery.critical {
        color: ${base08};
      }
      #cpu.warning {
        color: ${base0A};
      }
      #cpu.critical {
        color: ${base08};
      }
      #memory.warning {
        color: ${base0A};
      }
      #memory.critical {
        color: ${base08};
      }
      #disk.warning {
        color: ${base0A};
      }
      #disk.critical {
        color: ${base08};
      }
      #pulseaudio.high {
        color: ${base0A};
      }
      #pulseaudio.muted {
        color: ${base08};
      }
      #idle_inhibitor.activated {
        color: ${base08};
      }
      #custom-dunst.disabled {
        color: ${base08};
      }
      #custom-separator {
        color: ${base02};
      }
    '';
  };
}

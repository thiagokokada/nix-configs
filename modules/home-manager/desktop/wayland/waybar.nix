{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.home-manager.desktop.wayland.waybar;
  hyprlandCfg = config.home-manager.desktop.wayland.hyprland;
  swayCfg = config.home-manager.desktop.wayland.sway;

  dunstctl = lib.getExe' pkgs.dunst "dunstctl";
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.finalPackage "hyprctl";
  pamixer = lib.getExe pkgs.pamixer;
in
{
  options.home-manager.desktop.wayland.waybar = {
    enable = lib.mkEnableOption "Waybar config" // {
      default = config.home-manager.desktop.wayland.enable;
    };
    interval = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Block update default interval.";
    };
    backlight.enable = lib.mkEnableOption "backlight block" // {
      default = config.device.type == "laptop";
    };
    battery.enable = lib.mkEnableOption "battery block" // {
      default = config.device.type == "laptop";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      font-awesome_6
      nerd-fonts.symbols-only
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings =
        let
          icon-size = 24;
          height = 28;
        in
        {
          top =
            {
              inherit height;
              layer = "top";
              position = "top";
              spacing = 3;
              modules-left =
                lib.optionals hyprlandCfg.enable [
                  "hyprland/workspaces"
                  "hyprland/submap"
                ]
                ++ lib.optionals swayCfg.enable [
                  "sway/workspaces"
                  "sway/mode"
                ]
                ++ [ "wlr/taskbar" ];
              modules-center = [ "clock" ];
              modules-right =
                lib.pipe
                  [
                    "network"
                    "memory"
                    "cpu#load"
                    "temperature"
                    (lib.optionalString cfg.backlight.enable "backlight")
                    (lib.optionalString cfg.battery.enable "battery")
                    "wireplumber"
                    "custom/dunst"
                    "idle_inhibitor"
                    "tray"
                  ]
                  [
                    # Flatten lists
                    lib.flatten
                    # Filter optional modules
                    (lib.filter (m: m != ""))
                    # Add a separator between each module, except the last one
                    (builtins.concatMap (m: [
                      m
                      "custom/separator"
                    ]))
                    lib.init
                  ];
              "hyprland/workspaces" = lib.mkIf hyprlandCfg.enable {
                format = "{name}: {icon}";
                format-icons = {
                  "1" = " ";
                  "2" = " ";
                  "3" = " ";
                  "4" = " ";
                  "5" = " ";
                  "6" = " ";
                  "7" = " ";
                  "8" = " ";
                  "9" = " ";
                  "10" = " ";
                };
                "on-scroll-up" = "${hyprctl} dispatch workspace e+1";
                "on-scroll-down" = "${hyprctl} dispatch workspace e-1";
              };
              "hyprland/submap".tooltip = lib.mkIf hyprlandCfg.enable false;
              "sway/mode".tooltip = lib.mkIf swayCfg.enable false;
              "sway/workspaces".disable-scroll-wraparound = lib.mkIf swayCfg.enable true;
              "wlr/taskbar" = {
                inherit icon-size;
                format = "{icon}";
                on-click = "activate";
                on-click-middle = "close";
                icon = true;
              };
              idle_inhibitor = {
                format = "{icon}";
                format-icons = {
                  deactivated = "";
                  activated = "";
                };
                tooltip = false;
              };
              network = {
                inherit (cfg) interval;
                format = "󰈀 {bandwidthTotalBytes}";
                format-wifi = "{icon} {bandwidthTotalBytes}";
                format-ethernet = "󰈀 {bandwidthTotalBytes}";
                format-disconnected = "󰤮";
                format-icons = [
                  "󰤯"
                  "󰤟"
                  "󰤢"
                  "󰤥"
                  "󰤨"
                ];
                tooltip-format = lib.concatStringsSep "\n" [
                  "Interface: {ifname}"
                  "IP: {ipaddr}"
                  "Gateway: {gwaddr}"
                  "Netmask: {netmask}"
                  "Download: {bandwidthDownBytes}"
                  "Upload: {bandwidthUpBytes}"
                ];
                tooltip-format-wifi = lib.concatStringsSep "\n" [
                  "Interface: {ifname}"
                  "IP: {ipaddr}"
                  "Gateway: {gwaddr}"
                  "Netmask: {netmask}"
                  "SSID: {essid}"
                  "Signal: {signaldBm} dBm"
                  "Frequency: {frequency} GHz"
                  "Download: {bandwidthDownBytes}"
                  "Upload: {bandwidthUpBytes}"
                ];
              };
            }
            // {
              memory = {
                inherit (cfg) interval;
                format = " {avail:0.0f}G";
                format-alt = " {swapAvail:0.0f}G";
                states = {
                  warning = 75;
                  critical = 95;
                };
              };
              "cpu#load" = {
                inherit (cfg) interval;
                format = " {load:0.1f}";
              };
              temperature = {
                format = "{icon} {temperatureC}°C";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
                critical-threshold = 75;
              };
              "custom/dunst" = {
                exec = lib.getExe (
                  pkgs.writeShellApplication {
                    name = "dunst-status";
                    runtimeInputs = with pkgs; [
                      coreutils
                      dbus
                      dunst
                      procps
                    ];
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
                  }
                );
                on-click = "${dunstctl} set-paused toggle";
                restart-interval = 1;
                return-type = "json";
                tooltip = false;
              };
              "custom/separator" = {
                format = "|";
                interval = "once";
                tooltip = false;
              };
              wireplumber = {
                format = "{icon} {volume}%";
                format-muted = "";
                format-icons = [
                  ""
                  ""
                  ""
                ];
                on-click = config.home-manager.desktop.default.volumeControl;
                on-click-right = "${pamixer} --toggle-mute";
                scroll-step = 5;
                max-volume = 150;
                states = {
                  high = 101;
                };
              };
              backlight = {
                format = " {percent}%";
                on-scroll-up = "light -A 5%";
                on-scroll-down = "light -U 5%";
              };
              battery = {
                inherit (cfg) interval;
                format = "{icon} {capacity}%";
                format-icons = {
                  default = [
                    ""
                    ""
                    ""
                    ""
                    ""
                  ];
                  plugged = "";
                };
                states = {
                  warning = 20;
                  critical = 10;
                };
              };
              clock = {
                inherit (cfg) interval;
                format = "{:%H:%M, %a %d}";
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
      style =
        with config.home-manager.desktop.theme.colors;
        with config.home-manager.desktop.theme.fonts;
        let
          concatFonts =
            fonts:
            lib.pipe fonts [
              lib.flatten
              (map (s: ''"${s}"''))
              (lib.concatStringsSep ", ")
            ];
        in
        # css
        ''
          * {
            border: none;
            border-radius: 0;
            font-family: ${
              concatFonts [
                gui.name
                icons.name
                "Symbols Nerd Font"
              ]
            };
          }
          window#waybar {
            background: ${base00};
            color: ${base05};
          }
          #submap, #mode {
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
          #workspaces button.active,
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
          #wireplumber.high {
            color: ${base0A};
          }
          #wireplumber.muted {
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

    systemd.user.services.waybar = {
      Service = {
        inherit (config.home-manager.desktop.systemd.service) RestartSec RestartSteps RestartMaxDelaySec;
      };
    };
  };
}

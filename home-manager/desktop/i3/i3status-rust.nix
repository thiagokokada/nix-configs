{ config, lib, libEx, pkgs, ... }:

let
  cfg = config.home-manager.desktop.i3.i3status-rust;
in
{
  options.home-manager.desktop.i3.i3status-rust = {
    enable = lib.mkEnableOption "i3status-rust config" // {
      default = config.home-manager.desktop.i3.enable;
    };
    enableBacklight = lib.mkEnableOption "backlight block" // {
      default = config.device.type == "laptop";
    };
    enableBattery = lib.mkEnableOption "battery block" // {
      default = config.device.type == "laptop";
    };
    mountPoints = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Mount points to show in disk block";
      default = config.device.mountPoints;
    };
    netDevices = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Net devices to show in net block";
      default = config.device.netDevices;
    };
    interval = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Block update interval";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.i3status-rust = {
      enable = true;
      package = pkgs.i3status-rust;
      bars =
        let
          settings = {
            theme = {
              theme = "plain";
              overrides = with config.home-manager.desktop.theme.colors; {
                idle_bg = base00;
                idle_fg = base05;
                info_bg = base0D;
                info_fg = base00;
                good_bg = base00;
                good_fg = base05;
                warning_bg = base0A;
                warning_fg = base00;
                critical_bg = base08;
                critical_fg = base00;
                separator_bg = base00;
                separator = " ";
              };
            };
            icons = {
              icons = "awesome6";
              overrides = {
                caffeine = "";
                ethernet = "";
                memory_mem = "";
                memory_swap = "";
                microchip = "";
                monitor = "";
              };
            };
          };

          windowBlock = {
            block = "focused_window";
            format = " $title.str(max_w:26) |";
          };

          netBlocks = map
            (d: {
              inherit (cfg) interval;
              block = "net";
              device = d;
              format = " {$icon $ssid ($signal_strength) |^icon_ethernet } " +
                "^icon_net_up $speed_up.eng(prefix:K) " +
                "^icon_net_down $speed_down.eng(prefix:K) ";
              format_alt = " {$icon $ssid ($signal_strength) |^icon_ethernet } " +
                "^icon_net_up $graph_up.str(max_w:3) " +
                "^icon_net_down$graph_down.str(max_w:3) ";
              inactive_format = "";
              missing_format = "";
            })
            cfg.netDevices;

          disksBlocks = map
            (m: {
              inherit (cfg) interval;
              block = "disk_space";
              path = m;
              info_type = "available";
              format = " $icon ${libEx.shortPath m} $available ";
            })
            cfg.mountPoints;

          memoryBlock = {
            inherit (cfg) interval;
            block = "memory";
            format = " $icon $mem_avail ";
            format_alt = " $icon_swap $swap_free ";
          };

          cpuBlock = {
            inherit (cfg) interval;
            block = "cpu";
            format = " $icon " +
              "{$max_frequency.eng(prefix:G,w:3)} ";
            format_alt = " ^icon_microchip $barchart.str(max_w:3) $utilization ";
          };

          loadBlock = {
            inherit (cfg) interval;
            block = "load";
          };

          temperatureBlock = {
            inherit (cfg) interval;
            block = "temperature";
            format = " $icon $max ";
            chip = "*-isa-*";
            good = 20;
            idle = 55;
            info = 70;
            warning = 80;
          };

          backlightBlock = lib.optionalAttrs cfg.enableBacklight {
            block = "backlight";
            format = " ^icon_monitor $brightness |";
            invert_icons = true;
          };

          batteryBlock = lib.optionalAttrs cfg.enableBattery {
            block = "battery";
            device = "DisplayDevice";
            driver = "upower";
            format = " $icon $percentage {$time |}";
            missing_format = "";
          };

          soundBlock = {
            block = "sound";
            max_vol = 150;
            click = [
              {
                button = "left";
                cmd = "pavucontrol";
              }
            ];
          };

          notificationBlock = {
            block = "notify";
            format = " ^icon_notification " +
              "{$paused{^icon_toggle_off}|^icon_toggle_on} " +
              "{($notification_count.eng(w:1)) |}";
          };

          dpmsBlock =
            let xset = "${lib.getExe pkgs.xorg.xset}";
            in
            {
              inherit (cfg) interval;
              block = "toggle";
              format = " ^icon_caffeine $icon ";
              command_state = "${xset} q | grep -Fo 'DPMS is Enabled'";
              command_on = "${xset} s on +dpms";
              command_off = "${xset} s off -dpms";
              icon_on = "toggle_off";
              icon_off = "toggle_on";
            };

          timeBlock = {
            inherit (cfg) interval;
            block = "time";
          };

        in
        {
          i3 = {
            inherit settings;

            blocks = lib.pipe [
              windowBlock
              netBlocks
              disksBlocks
              memoryBlock
              cpuBlock
              temperatureBlock
              loadBlock
              notificationBlock
              dpmsBlock
              backlightBlock
              batteryBlock
              soundBlock
              timeBlock
            ] [
              lib.lists.flatten
              (lib.filter (b: b != { }))
            ];
          };
        };
    };
  };
}

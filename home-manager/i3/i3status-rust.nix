{ config, lib, pkgs, ... }:
{
  imports = [ ../../modules/device.nix ];

  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;
    bars =
      let
        interval = 5;
        isLaptop = config.device.type == "laptop";

        settings = {
          theme = {
            theme = "plain";
            overrides = with config.theme.colors; {
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

        netBlocks = with config.device; map
          (d: {
            interval = 2;
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
          netDevices;

        disksBlocks = with config.device;
          let
            shortPath = with lib.strings;
              (path: concatStringsSep "/" (map (substring 0 1) (splitString "/" path)));
          in
          map
            (m: {
              inherit interval;
              block = "disk_space";
              path = m;
              info_type = "available";
              format = " $icon ${shortPath m} $available ";
            })
            mountPoints;

        memoryBlock = {
          inherit interval;
          block = "memory";
          format = " $icon $mem_avail ";
          format_alt = " $icon_swap $swap_free ";
        };

        cpuBlock = {
          inherit interval;
          block = "cpu";
          format = " $icon " +
            "{$max_frequency.eng(prefix:G,w:3)} ";
          format_alt = " ^icon_microchip $barchart.str(max_w:3) $utilization ";
        };

        loadBlock = {
          inherit interval;
          block = "load";
        };

        temperatureBlock = {
          inherit interval;
          block = "temperature";
          format = " $icon $max ";
          chip = "*-isa-*";
          good = 20;
          idle = 55;
          info = 70;
          warning = 80;
        };

        backlightBlock = lib.optionalAttrs isLaptop {
          block = "backlight";
          format = " ^icon_monitor $brightness |";
          invert_icons = true;
        };

        batteryBlock = lib.optionalAttrs isLaptop {
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
          let xset = "${pkgs.xorg.xset}/bin/xset";
          in
          {
            inherit interval;
            block = "toggle";
            format = " ^icon_caffeine $icon ";
            command_state = "${xset} q | grep -Fo 'DPMS is Enabled'";
            command_on = "${xset} s on +dpms";
            command_off = "${xset} s off -dpms";
            icon_on = "toggle_off";
            icon_off = "toggle_on";
          };

        timeBlock = {
          inherit interval;
          block = "time";
        };

      in
      {
        i3 = {
          inherit settings;

          blocks = lib.filter (b: b != { }) (lib.lists.flatten [
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
          ]);
        };
      };
  };
}

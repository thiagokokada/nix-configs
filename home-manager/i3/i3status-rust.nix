{ config, lib, pkgs, ... }:
let
  shortPath = with lib.strings;
    (path: concatStringsSep "/" (map (substring 0 1) (splitString "/" path)));
in
{
  imports = [ ../../modules/device.nix ];

  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;
    bars =
      let
        interval = 5;
        isKbddEnabled = config.systemd.user.services ? kbdd;

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
              memory_mem = "";
              memory_swap = "";
              disk_drive = "";
              caffeine_on = " ";
              caffeine_off = " ";
              notification_on = " ";
              notification_off = " ";
              microchip = "";
            };
          };
        };

        windowBlock = {
          block = "focused_window";
          format = " $title.str(max_w:51) |";
        };

        netBlocks = with config.device; map
          (d: {
            interval = 2;
            block = "net";
            device = d;
            format = " $icon {$ssid ($signal_strength) |} ^icon_net_up $speed_up.eng(prefix:K) ^icon_net_down $speed_down.eng(prefix:K) ";
            missing_format = "";
          })
          netDevices;

        disksBlocks = with config.device; map
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
          format = " $icon {$frequency.eng(prefix:G,w:3)|$max_frequency.eng(prefix:G,w:3)} ";
          format_alt = " ^icon_microchip $barchart.str(max_w:3) $utilization ";
        };

        loadBlock = {
          inherit interval;
          block = "load";
        };

        temperatureBlock = {
          inherit interval;
          block = "temperature";
          format = " $icon $average ";
          chip = "*-acpi-*";
          good = 20;
          idle = 55;
          info = 70;
          warning = 80;
        };

        backlightBlock = {
          block = "backlight";
          format = " $icon $brightness |";
          invert_icons = true;
        };

        batteryBlock = {
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

        keyboardBlock = lib.optionalAttrs isKbddEnabled {
          block = "keyboard_layout";
          format = " $icon $layout ";
          driver = "kbddbus";
        };

        notificationBlock =
          let
            dunstctl = "${pkgs.dunst}/bin/dunstctl";
            grep = "${pkgs.gnugrep}/bin/grep";
          in
          {
            inherit interval;
            block = "toggle";
            format = " $icon ";
            command_state = "${dunstctl} is-paused | ${grep} -Fo 'false'";
            command_on = "${dunstctl} set-paused false && ${dunstctl} is-paused";
            command_off = "${dunstctl} set-paused true && ${dunstctl} is-paused";
            icon_on = "notification_on";
            icon_off = "notification_off";
          };

        dpmsBlock =
          let xset = "${pkgs.xorg.xset}/bin/xset";
          in
          {
            inherit interval;
            block = "toggle";
            format = " $icon ";
            command_state = "${xset} q | grep -Fo 'DPMS is Enabled'";
            command_on = "${xset} s on +dpms";
            command_off = "${xset} s off -dpms";
            icon_on = "caffeine_off";
            icon_off = "caffeine_on";
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
            loadBlock
            temperatureBlock
            notificationBlock
            dpmsBlock
            backlightBlock
            batteryBlock
            soundBlock
            keyboardBlock
            timeBlock
          ]);
        };

        sway = {
          inherit settings;

          blocks = lib.filter (b: b != { }) (lib.lists.flatten [
            windowBlock
            netBlocks
            disksBlocks
            memoryBlock
            cpuBlock
            loadBlock
            temperatureBlock
            backlightBlock
            batteryBlock
            soundBlock
            (keyboardBlock // { driver = "sway"; })
            timeBlock
          ]);
        };
      };
  };
}

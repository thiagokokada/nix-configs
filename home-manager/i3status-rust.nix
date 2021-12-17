{ config, lib, pkgs, ... }:
let
  shortPath = with lib.strings;
    (path: concatStringsSep "/" (map (substring 0 1) (splitString "/" path)));
in
{
  imports = [ ../modules/device.nix ];

  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;
    bars =
      let
        isNotebook = config.device.type == "notebook";

        settings = {
          theme = {
            name = "plain";
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
            name = "awesome5";
            overrides = {
              memory_swap = " ";
              disk_drive = " ";
              caffeine_on = "  ";
              caffeine_off = "  ";
              notification_on = "  ";
              notification_off = "  ";
            };
          };
        };

        windowBlock = {
          block = "focused_window";
          max_width = 50;
          show_marks = "visible";
        };

        netBlocks = with config.device; map
          (d: {
            block = "net";
            device = d;
            hide_missing = true;
            hide_inactive = true;
            format = "{ssid} {speed_up} {speed_down}";
          })
          netDevices;

        disksBlocks = with config.device; map
          (m: {
            block = "disk_space";
            path = m;
            info_type = "available";
            unit = "GB";
            format = "{icon} ${shortPath m} {available}";
          })
          # Remove envfs entries
          (builtins.filter
            (m: (m != "/bin") && (m != "/usr/bin"))
            mountPoints);

        memoryBlock = {
          block = "memory";
          format_mem = "{mem_avail;G}";
          format_swap = "{swap_free;G}";
        };

        cpuBlock = {
          block = "cpu";
          format = "{frequency}";
        };

        loadBlock = { block = "load"; };

        temperatureBlock = {
          block = "temperature";
          format = "{average}";
          collapsed = false;
          chip = "coretemp-*";
          good = 20;
          idle = 55;
          info = 70;
          warning = 80;
        };

        backlightBlock = if isNotebook then { block = "backlight"; } else { };

        batteryBlock =
          if isNotebook then {
            block = "battery";
            device = "DisplayDevice";
            driver = "upower";
            format = "{percentage} {time}";
          } else
            { };

        soundBlock = {
          block = "sound";
          on_click = "pavucontrol";
          max_vol = 150;
        };

        keyboardBlock = {
          block = "keyboard_layout";
          format = " {layout}";
          driver = "kbddbus";
        };

        notificationBlock =
          let
            dunstctl = "${pkgs.dunst}/bin/dunstctl";
            grep = "${pkgs.gnugrep}/bin/grep";
          in
          {
            block = "toggle";
            command_state = "${dunstctl} is-paused | ${grep} -Fo 'false'";
            command_on = "${dunstctl} set-paused false && ${dunstctl} is-paused";
            command_off = "${dunstctl} set-paused true && ${dunstctl} is-paused";
            icon_on = "notification_on";
            icon_off = "notification_off";
            interval = 5;
          };

        dpmsBlock =
          let xset = "${pkgs.xorg.xset}/bin/xset";
          in
          {
            block = "toggle";
            command_state = "${xset} q | grep -Fo 'DPMS is Enabled'";
            command_on = "${xset} s on +dpms";
            command_off = "${xset} s off -dpms";
            icon_on = "caffeine_off";
            icon_off = "caffeine_on";
            interval = 5;
          };

        timeBlock = {
          block = "time";
          interval = 1;
          format = "%a %T";
        };

      in
      {
        i3 = {
          inherit settings;

          blocks = lib.lists.flatten [
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
          ];
        };

        sway = {
          inherit settings;

          blocks = lib.lists.flatten [
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
          ];
        };
      };
  };
}

{ config, lib, pkgs, inputs, ... }:

let
  shortPath = with lib.strings;
    (path: concatStringsSep "/" (map (substring 0 1) (splitString "/" path)));
in {
  programs.i3status-rust = {
    enable = true;
    package = pkgs.unstable.i3status-rust;
    bars = let
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
          };
        };
      };

      windowBlock = {
        block = "focused_window";
        max_width = 50;
        show_marks = "visible";
      };

      netBlock = {
        block = "net";
        hide_missing = true;
        hide_inactive = true;
        format = "{ssid} {speed_up} {speed_down}";
      };

      disksBlocks = with config.device; map (m: {
        block = "disk_space";
        path = m;
        alias = shortPath m;
        info_type = "available";
        unit = "GiB";
        format = "{icon}{alias} {available}G";
      }) mountPoints;

      memoryBlock = {
        block = "memory";
        format_mem = "{MAg}G";
        format_swap = "{SFg}G";
      };

      loadBlock = { block = "load"; };

      temperatureBlock = {
        block = "temperature";
        format = "{average}°C";
        collapsed = false;
        chip = "coretemp-*";
        good = 20;
        idle = 55;
        info = 70;
        warning = 80;
      };

      backlightBlock = if isNotebook then { block = "backlight"; } else { };

      batteryBlock = if isNotebook then {
        block = "battery";
        device = "DisplayDevice";
        driver = "upower";
        format = "{percentage}% {time}";
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

      dpmsBlock = let xset = "${pkgs.xorg.xset}/bin/xset";
      in {
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

    in {
      i3 = {
        inherit settings;
        blocks = lib.lists.flatten [
          windowBlock
          netBlock
          disksBlocks
          memoryBlock
          loadBlock
          temperatureBlock
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
          netBlock
          disksBlocks
          memoryBlock
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

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.window-manager.x11.i3status-rust;
in
{
  options.home-manager.window-manager.x11.i3status-rust = {
    enable = lib.mkEnableOption "i3status-rust config" // {
      default = config.home-manager.window-manager.x11.enable;
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
    net.ifaces = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Net interfaces to show in net block.";
      default = config.device.net.ifaces;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.i3status-rust = {
      enable = true;
      bars =
        let
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

          netBlocks = map (d: {
            inherit (cfg) interval;
            block = "net";
            device = d;
            format = " {$icon|^icon_ethernet} $speed_down.eng(prefix:K) ";
            inactive_format = "";
            missing_format = "";
          }) cfg.net.ifaces;

          diskBlock = {
            inherit (cfg) interval;
            block = "disk_space";
            info_type = "available";
            format = " $icon $percentage ";
          };

          memoryBlock = {
            inherit (cfg) interval;
            block = "memory";
            format = " $icon $mem_avail ";
            format_alt = " $icon_swap $swap_free ";
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

          backlightBlock = lib.optionalAttrs cfg.backlight.enable {
            block = "backlight";
            format = " ^icon_monitor $brightness |";
            invert_icons = true;
          };

          batteryBlock = lib.optionalAttrs cfg.battery.enable {
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
                cmd = config.home-manager.window-manager.default.volumeControl;
              }
            ];
          };

          notificationBlock = {
            block = "notify";
            format = " ^icon_notification {$paused{^icon_toggle_off}|^icon_toggle_on} ";
          };

          dpmsBlock =
            let
              xset = "${lib.getExe pkgs.xset}";
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
            format = " $icon $timestamp.datetime(f:'%H:%M, %a %d') ";
          };
        in
        {
          i3 = {
            inherit settings;

            blocks =
              lib.pipe
                [
                  netBlocks
                  diskBlock
                  memoryBlock
                  temperatureBlock
                  loadBlock
                  backlightBlock
                  batteryBlock
                  soundBlock
                  notificationBlock
                  dpmsBlock
                  timeBlock
                ]
                [
                  lib.lists.flatten
                  (lib.filter (b: b != { }))
                ];
          };
        };
    };
  };
}

{ config, lib, ... }:

let
  cfg = config.nixos.desktop.audio;
in
{
  options.nixos.desktop.audio = {
    enable = lib.mkEnableOption "audio config" // {
      default = config.nixos.desktop.enable;
    };
    lowLatency = {
      enable = lib.mkEnableOption "low latency config" // {
        default = config.nixos.games.enable;
      };
      quantum = lib.mkOption {
        description = "Quantum.";
        type = lib.types.int;
        default = 128;
        example = 32; # lowest latency possible
      };
      rate = lib.mkOption {
        description = "Audio rate.";
        type = lib.types.int;
        default = 48000;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # This allows PipeWire to run with realtime privileges (i.e: less cracks)
    security.rtkit.enable = true;

    services = {
      pipewire = {
        alsa.support32Bit = config.nixos.games.enable;
        extraConfig = lib.mkIf cfg.lowLatency.enable {
          pipewire."92-low-latency" = {
            context.properties = {
              default.clock.rate = cfg.lowLatency.rate;
              default.clock.quantum = cfg.lowLatency.quantum;
              default.clock.min-quantum = cfg.lowLatency.quantum;
              default.clock.max-quantum = cfg.lowLatency.quantum;
            };
          };
          pipewire-pulse."92-low-latency" =
            let
              req = "${toString cfg.lowLatency.quantum}/${toString cfg.lowLatency.rate}";
            in
            {
              context.modules = [
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = {
                    pulse.min.req = req;
                    pulse.default.req = req;
                    pulse.max.req = req;
                    pulse.min.quantum = req;
                    pulse.max.quantum = req;
                  };
                }
              ];
              stream.properties = {
                node.latency = req;
                resample.quality = 1;
              };
            };
        };
        wireplumber = {
          enable = true;
          extraConfig."10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.roles" = [
                "hsp_hs"
                "hsp_ag"
                "hfp_hf"
                "hfp_ag"
              ];
            };
          };
        };
      };
    };
  };
}

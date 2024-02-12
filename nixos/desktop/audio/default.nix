{ config, lib, ... }:

let
  cfg = config.nixos.desktop.audio;
in
{
  options.nixos.desktop.audio = {
    enable = lib.mkEnableOption "audio config" // {
      default = config.nixos.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    # Wireplumber config
    environment.etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };

    # This allows PipeWire to run with realtime privileges (i.e: less cracks)
    security.rtkit.enable = true;

    services = {
      pipewire = {
        enable = true;
        audio.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
      };
    };
  };
}

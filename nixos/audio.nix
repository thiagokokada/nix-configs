{ config, lib, pkgs, ... }:

{
  options.nixos.audio.enable = pkgs.lib.mkDefaultOption "audio config";

  config = lib.mkIf config.nixos.audio.enable {
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

    security = {
      # This allows PipeWire to run with realtime privileges (i.e: less cracks)
      rtkit.enable = true;
    };

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

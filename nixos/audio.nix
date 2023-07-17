{ flake, config, lib, ... }:

{
  imports = [ flake.inputs.nix-gaming.nixosModules.pipewireLowLatency ];

  options.nixos.audio = {
    enable = lib.mkDefaultOption "audio config";
    lowLatency = {
      enable = lib.mkEnableOption "low latency config";
      quantum = lib.mkOption {
        description = "Minimum quantum to set";
        type = lib.types.int;
        default = 64;
        example = 32;
      };
      rate = lib.mkOption {
        description = "Rate to set";
        type = lib.types.int;
        default = 48000;
        example = 96000;
      };
    };
  };

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
        lowLatency = {
          inherit (config.nixos.audio.lowLatency) enable quantum rate;
        };
      };
    };
  };
}

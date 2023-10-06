{ flake, config, lib, ... }:

let
  cfg = config.nixos.desktop.audio;
in
{
  imports = [ flake.inputs.nix-gaming.nixosModules.pipewireLowLatency ];

  options.nixos.desktop.audio = {
    enable = lib.mkEnableOption "audio config" // {
      default = config.nixos.desktop.enable;
    };
    lowLatency = {
      enable = lib.mkEnableOption "low latency config" // {
        default = config.nixos.games.enable;
      };
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
        lowLatency = {
          inherit (cfg.lowLatency) enable quantum rate;
        };
      };
    };
  };
}

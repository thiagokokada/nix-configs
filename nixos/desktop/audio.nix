{ config, lib, pkgs, flake, ... }:

let
  cfg = config.nixos.desktop.audio;
in
{
  imports = [ flake.inputs.nix-gaming.nixosModules.pipewireLowLatency ];

  options.nixos.desktop.audio = {
    enable = lib.mkEnableOption "audio config" // {
      default = config.nixos.desktop.enable;
    };
    lowLatency.enable = lib.mkEnableOption "low latency config" // {
      default = config.nixos.games.enable;
    };
  };

  config = lib.mkIf cfg.enable {
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
        lowLatency = {
          inherit (cfg.lowLatency) enable;
          # The default for this module is 64 that generally is too low and
          # generates e.g.: cracking
          quantum = lib.mkDefault 128;
        };
        wireplumber = {
          enable = true;
          configPackages =
            let
              properties = lib.generators.toLua { } {
                "bluez5.enable-sbc-xq" = true;
                "bluez5.enable-msbc" = true;
                "bluez5.enable-hw-volume" = true;
                "bluez5.headset-roles" = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]";
              };
            in
            [
              (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" /* lua */ ''
                bluez_monitor.properties = ${properties}
              '')
            ];
        };
      };
    };
  };
}

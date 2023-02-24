{ flake, pkgs, lib, config, ... }:

let
  nvidia-offload = lib.findFirst (p: lib.isDerivation p && p.name == "nvidia-offload")
    null
    config.environment.systemPackages;
  import-osu-songs = pkgs.writeShellApplication {
    name = "import-osu-songs";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      declare -r osu_song_dir="$HOME/.osu/drive_c/osu/Songs"
      mkdir -p "$osu_song_dir"
      cp -v "''${@}" "$osu_song_dir"
    '';
  };
in
{
  imports = [ flake.inputs.nix-gaming.nixosModules.pipewireLowLatency ];

  # Fix: MESA-INTEL: warning: Performance support disabled, consider sysctl dev.i915.perf_stream_paranoid=0
  boot.kernelParams = [ "dev.i915.perf_stream_paranoid=0" ];

  environment = {
    systemPackages = with pkgs; [
      gaming.osu-stable
      gaming.osu-lazer-bin
      import-osu-songs
      lutris
      piper
      retroarchFull
    ];

    # Use nvidia-offload script in gamemode
    variables.GAMEMODERUNEXEC = lib.mkIf (nvidia-offload != null)
      "${nvidia-offload}/bin/nvidia-offload";
  };

  programs = {
    gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };

  hardware = {
    # Enable opentabletdriver (for osu!)
    opentabletdriver = {
      enable = true;
      package = pkgs.opentabletdriver;
    };

    # Alternative driver for Xbox One/Series S/Series X controllers
    xpadneo.enable = true;
  };

  services = {
    # Enable ratbagd (i.e.: piper) for Logitech devices
    ratbagd.enable = true;
    # https://github.com/fufexan/nix-gaming/blob/master/modules/pipewireLowLatency.nix
    pipewire.lowLatency.enable = true;
  };
}

{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.nixos.games;
  nvidia-offload = lib.findFirst (
    p: lib.isDerivation p && p.name == "nvidia-offload"
  ) null config.environment.systemPackages;
in
{
  imports = [
    ./osu.nix
    ./ratbag.nix
    ./retroarch.nix
    ./steam.nix
  ];

  options.nixos.games = {
    enable = lib.mkEnableOption "games config";
    gpu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "amd"
          "intel"
          "nvidia"
        ]
      );
      default = null;
      description = "GPU maker.";
    };
  };

  config = lib.mkIf cfg.enable {
    # https://fedoraproject.org/wiki/Changes/IncreaseVmMaxMapCount
    # https://pagure.io/fesco/issue/2993#comment-859763
    boot.kernel.sysctl."vm.max_map_count" = 1048576;

    environment = {
      systemPackages = with pkgs; [ lutris ];

      # Use nvidia-offload script in gamemode
      variables.GAMEMODERUNEXEC = lib.mkIf (
        cfg.gpu == "nvidia" && nvidia-offload != null
      ) "${nvidia-offload}/bin/nvidia-offload";
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        custom = {
          start = "${lib.getExe pkgs.libnotify} 'GameMode started'";
          end = "${lib.getExe pkgs.libnotify} 'GameMode ended'";
        };
      };
    };

    # Alternative driver for Xbox One/Series S/Series X controllers
    # hardware.xone.enable = true;
  };
}

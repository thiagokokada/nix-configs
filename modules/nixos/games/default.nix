{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.meta) username;
  cfg = config.nixos.games;
  nvidia-offload = lib.findFirst (
    p: lib.isDerivation p && p.name == "nvidia-offload"
  ) null config.environment.systemPackages;
in
{
  imports = [
    ./jovian.nix
    ./osu.nix
    ./ratbag.nix
    ./retroarch.nix
    ./steam.nix
  ];

  options.nixos.games = {
    enable = lib.mkEnableOption "games config" // {
      default = config.device.type == "steam-machine";
    };
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
        gpu = lib.mkIf (cfg.gpu == "amd") {
          apply_gpu_optimisations = "accept-responsibility"; # For systems with AMD GPUs
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };

    users.users.${username}.extraGroups = [ "gamemode" ];

    hardware = {
      # Alternative driver for Xbox One/Series S/Series X controllers
      xone.enable = true;
      # OpenCL for AMD GPUs
      graphics.extraPackages = with pkgs; lib.optionals (cfg.gpu == "amd") [ rocmPackages.clr.icd ];
    };

    # ROCm packages
    # TODO: move this somewhere else
    systemd.tmpfiles.rules =
      let
        rocmEnv = pkgs.symlinkJoin {
          name = "rocm-combined";
          paths = with pkgs.rocmPackages; [
            rocblas
            hipblas
            clr
          ];
        };
      in
      lib.optionals (cfg.gpu == "amd") [ "L+ /opt/rocm - - - - ${rocmEnv}" ];
  };
}

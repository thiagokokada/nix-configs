{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.nixos.system) gpu;
in
{
  options.nixos.system.gpu = lib.mkOption {
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

  config = lib.mkMerge [
    (lib.mkIf (gpu == "amd") {
      # Enable support for ROCm in nixpkgs
      nixpkgs.config.rocmSupport = true;

      hardware = {
        # Needed for lact
        amdgpu.overdrive.enable = true;
        # OpenCL for AMD GPUs
        graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];
      };

      programs.gamemode = {
        settings.gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          # Override this in host for multi-GPU systems
          gpu_device = lib.mkDefault 0;
          amd_performance_level = "high";
        };
      };

      # ROCm packages
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
        [ "L+ /opt/rocm - - - - ${rocmEnv}" ];
    })
    (
      let
        primeEnabled =
          config.hardware.nvidia.prime.offload.enable || config.hardware.nvidia.prime.reverseSync.enable;
      in
      lib.mkIf (gpu == "nvidia") {
        # Enable support for CUDA in nixpkgs
        nixpkgs.config.cudaSupport = true;

        # Use nvidia-offload script in gamemode
        environment.variables.GAMEMODERUNEXEC = lib.mkIf primeEnabled "/run/current-system/sw/bin/${config.hardware.nvidia.prime.offload.offloadCmdMainProgram}";

        hardware.nvidia.prime.offload.enableOffloadCmd = primeEnabled;
      }
    )
    (lib.mkIf (gpu != null) {
      # GPU control application
      services.lact.enable = config.nixos.desktop.enable;
    })
  ];
}

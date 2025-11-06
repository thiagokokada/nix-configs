{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixos.system.gpu;
  inherit (cfg) maker;
in
{
  options.nixos.system.gpu = {
    maker = lib.mkOption {
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
    acceleration.enable = lib.mkEnableOption "CUDA/ROCm support";
  };

  config = lib.mkMerge [
    (lib.mkIf (maker == "amd") {
      hardware = {
        # Needed for lact
        amdgpu.overdrive.enable = true;
        # OpenCL for AMD GPUs
        graphics.extraPackages =
          with pkgs;
          lib.mkIf cfg.acceleration.enable [
            rocmPackages.clr.icd
          ];
      };

      programs.gamemode = {
        settings.gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          # Override this in host for multi-GPU systems
          gpu_device = lib.mkDefault 0;
          amd_performance_level = "high";
        };
      };
    })
    (lib.mkIf (maker == "amd" && cfg.acceleration.enable) {
      # Enable support for ROCm in nixpkgs
      nixpkgs.config.rocmSupport = true;

      # OpenCL for AMD GPUs
      hardware.graphics.extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];

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
        inherit (config.hardware.nvidia.prime.offload) offloadCmdMainProgram;
        primeEnabled =
          config.hardware.nvidia.prime.offload.enable || config.hardware.nvidia.prime.reverseSync.enable;
      in
      lib.mkIf (maker == "nvidia") {
        nixos.home.extraModules = {
          home-manager.window-manager.x11.nvidia = {
            enable = true;
            prime = {
              sync = { inherit (config.hardware.nvidia.prime.sync) enable; };
              offload = { inherit (config.hardware.nvidia.prime.offload) enable; };
            };
          };
        };

        # Use nvidia-offload script in gamemode
        environment.variables.GAMEMODERUNEXEC = lib.mkIf primeEnabled "/run/current-system/sw/bin/${offloadCmdMainProgram}";

        hardware.nvidia.prime.offload.enableOffloadCmd = primeEnabled;
      }
    )
    (lib.mkIf (maker == "nvidia" && cfg.acceleration.enable) {
      # Enable support for CUDA in nixpkgs
      nixpkgs.config.cudaSupport = true;
    })
    (lib.mkIf (maker != null) {
      # GPU control application
      services.lact.enable = config.nixos.desktop.enable;
    })
  ];
}

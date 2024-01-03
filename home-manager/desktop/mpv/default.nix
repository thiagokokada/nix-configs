{ config, lib, pkgs, ... }:

let
  cfg = config.home-manager.desktop.mpv;
in
{
  options.home-manager.desktop.mpv = {
    enable = lib.mkEnableOption "mpv config" // {
      default = config.home-manager.desktop.enable;
    };
    enableVapoursynth = lib.mkEnableOption "Vapoursynth config" // {
      default = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.vapoursynth;
    };
    enableHQ = lib.mkEnableOption "high-quality config (needs good CPU/GPU)";
    defaultProfiles = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "gpu-hq" ];
      description = "Default mpv profiles.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (python3Packages.yt-dlp.override { withAlias = true; })
    ];

    programs.mpv = {
      enable = true;

      package = with pkgs;
        if (!cfg.enableVapoursynth) then
          lib.mkDefault pkgs.mpv
        else
          wrapMpv (mpv-unwrapped.override { vapoursynthSupport = true; }) {
            extraMakeWrapperArgs = [
              "--prefix"
              "LD_LIBRARY_PATH"
              ":"
              "${vapoursynth-mvtools}/lib/vapoursynth"
            ];
          };

      config = {
        osd-font-size = 14;
        osd-level = 3;
        slang = "enUS,enGB,en,eng,ptBR,pt,por";
        alang = "ja,jpn,enUS,enGB,en,eng,ptBR,pt,por";
        profile = cfg.defaultProfiles;
      };

      profiles = {
        color-correction = {
          target-prim = "bt.709";
          target-trc = "bt.1886";
          icc-profile-auto = true;
        };

        interpolation = {
          interpolation = true;
          tscale = "box";
          tscale-window = "quadric";
          tscale-clamp = 0.0;
          tscale-radius = 1.025;
          video-sync = "display-resample";
          blend-subtitles = "video";
        };

        hq-scale = {
          scale = "ewa_lanczossharp";
          dscale = "mitchell";
          cscale = "spline36"; # alternatively ewa_lanczossoft
        };

        hwdec = {
          hwdec = "auto";
        };
      };

      bindings = {
        F1 = "seek -85";
        F2 = "seek 85";
        "CTRL+i" = lib.mkIf cfg.enableVapoursynth "vf toggle vapoursynth=${./motion-based-interpolation.vpy}";
      } //
      (if cfg.enableHQ then {
        # HQ variants
        "CTRL+1" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';
      } else {
        # Fast variants
        "CTRL+1" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A (Fast)"'';
        "CTRL+2" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B (Fast)"'';
        "CTRL+3" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C (Fast)"'';
        "CTRL+4" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode A+A (Fast)"'';
        "CTRL+5" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_Soft_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode B+B (Fast)"'';
        "CTRL+6" = ''no-osd change-list glsl-shaders set "${pkgs.anime4k}/Anime4K_Clamp_Highlights.glsl:${pkgs.anime4k}/Anime4K_Upscale_Denoise_CNN_x2_M.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${pkgs.anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${pkgs.anime4k}/Anime4K_Restore_CNN_S.glsl:${pkgs.anime4k}/Anime4K_Upscale_CNN_x2_S.glsl"; show-text "Anime4K: Mode C+A (Fast)"'';
        "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
      });
    };
  };
}

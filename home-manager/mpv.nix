{ config, lib, pkgs, inputs, ... }:

{
  programs.mpv = {
    enable = true;

    package = with pkgs; wrapMpv (mpv-unwrapped.override { vapoursynthSupport = true; }) {
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
      profile = [ "gpu-hq" "interpolation" ];
    };

    profiles = {
      color-correction = {
        target-prim = "bt.709";
        target-trc = "bt.1886";
        gamma-auto = true;
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
        cscale = "ewa_lanczossharp";
      };

      low-power = {
        profile = "gpu-hq";
        hwdec = "auto";
        deband = false;
        interpolation = false;
      };
    };

    bindings = {
      F1 = "seek -85";
      F2 = "seek 85";
      I = "vf toggle vapoursynth=${./scripts/motion-based-interpolation.vpy}";
    };
  };
}

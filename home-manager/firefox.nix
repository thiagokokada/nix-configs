{ config, lib, pkgs, self, ... }:

let inherit (config.home) username;
in
{
  programs.firefox = {
    enable = true;
    profiles.${username} = {
      settings = {
        # https://wiki.archlinux.org/title/Firefox#Hardware_video_acceleration
        "gfx.webrender.compositor" = true;
        "gfx.x11-egl.force-enabled" = true;
        "browser.quitShortcut.disabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.ffvpx.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
      };
    };
  };
}

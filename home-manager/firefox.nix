{ config, lib, pkgs, self, ... }:

let inherit (config.home) username;
in
{
  programs.firefox = {
    enable = true;
    # Until https://github.com/NixOS/nixpkgs/commit/c7b69587024dd597fe3dd5d8c8af08bd907367aa
    # hits nixos-21.11.
    package = self.inputs.staging.legacyPackages.${pkgs.hostPlatform.system}.firefox;
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

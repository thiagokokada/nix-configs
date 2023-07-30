{ config, pkgs, lib, ... }:

{
  options.nixos.fonts.enable = lib.mkDefaultOption "fonts config";

  config = lib.mkIf config.nixos.fonts.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
      ];

      fontconfig = {
        defaultFonts = {
          monospace = [ "Noto Sans Mono" ];
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

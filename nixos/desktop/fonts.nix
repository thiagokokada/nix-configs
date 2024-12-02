{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.nixos.desktop.fonts.enable = lib.mkEnableOption "fonts config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.fonts.enable {
    fonts = {
      fontDir.enable = true;

      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
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

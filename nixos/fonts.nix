{ config, lib, pkgs, self, ... }:

{
  imports = [ "${self.inputs.add-hintstyle-config}/nixos/modules/config/fonts/fontconfig.nix" ];
  disabledModules = [ "config/fonts/fontconfig.nix" ];

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [
      corefonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Mono" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}

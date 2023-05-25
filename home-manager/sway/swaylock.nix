{ config, pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      effect-pixelate = 60;
      font = config.theme.fonts.gui.name;
      indicator-caps-lock = true;
      screenshots = true;
      show-keyboard-layout = true;
    };
  };
}

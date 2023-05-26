{ config, pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = with config.theme.colors; {
      effect-pixelate = 120;
      font = config.theme.fonts.gui.name;
      indicator-caps-lock = true;
      screenshots = true;
      show-keyboard-layout = true;

      inside-color = base01;
      line-color = base01;
      ring-color = base05;
      text-color = base05;

      inside-clear-color = base0A;
      line-clear-color = base0A;
      ring-clear-color = base00;
      text-clear-color = base00;

      inside-caps-lock-color = base03;
      line-caps-lock-color = base03;
      ring-caps-lock-color = base00;
      text-caps-lock-color = base00;

      inside-ver-color = base0D;
      line-ver-color = base0D;
      ring-ver-color = base00;
      text-ver-color = base00;

      inside-wrong-color = base08;
      line-wrong-color = base08;
      ring-wrong-color = base00;
      text-wrong-color = base00;

      caps-lock-bs-hl-color = base08;
      caps-lock-key-hl-color = base0C;
      bs-hl-color = base08;
      key-hl-color = base0C;
      separator-color = "#00000000"; # transparent
    };
  };
}

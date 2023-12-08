{ config, pkgs, lib, ... }:

{
  options.home-manager.desktop.sway.swaylock.enable = lib.mkEnableOption "swaylock config" // {
    default = config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.sway.swaylock.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock;
      settings = with config.home-manager.desktop.theme.colors; {
        font = config.home-manager.desktop.theme.fonts.gui.name;
        indicator-caps-lock = true;
        show-keyboard-layout = true;
        # https://stackoverflow.com/a/506662
        image = with pkgs; toString
          (runCommand "wallpaper-pixelated" { buildInputs = [ imagemagick ]; } ''
            convert -scale 1% -scale 10000% ${config.home-manager.desktop.theme.wallpaper.path} $out
          '');
        scaling = config.home-manager.desktop.theme.wallpaper.scale;

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
        layout-bg-color = "#00000050"; # semi-transparent black

        indicator-radius = 80;
        indicator-thickness = 10;
      };
    };
  };
}

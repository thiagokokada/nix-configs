{ config, lib, pkgs, ... }:
let
  wofiConfig = {
    key_left = "Control_L-h";
    key_down = "Control_L-j";
    key_up = "Control_L-k";
    key_right = "Control_L-l";
    term = "${pkgs.kitty}/bin/kitty";
    insensitive = true;
  };

  wofiTheme = with config.theme.colors; ''
    window {
      margin: 0px;
      border: 1px solid ${base01};
      background-color: ${base00};
    }

    #input {
      margin: 5px;
      border: none;
      color: ${base05};
      background-color: ${base01};
    }

    #inner-box {
      margin: 5px;
      border: none;
      background-color: ${base01};
    }

    #outer-box {
      margin: 5px;
      border: none;
      background-color: ${base01};
    }

    #scroll {
      margin: 0px;
      border: none;
    }

    #text {
      margin: 5px;
      border: none;
      color: ${base05};
    }

    #text:selected {
      color: ${base00};
    }

    #entry:selected {
      background-color: ${base0D};
      color: ${base00};
    }
  '';
in
{
  xdg.configFile."wofi/style.css".text = wofiTheme;
  xdg.configFile."wofi/config".text = lib.generators.toKeyValue { } wofiConfig;
  home.packages = with pkgs; [ j4-dmenu-desktop wofi ];
}

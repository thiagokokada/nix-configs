{
  config,
  lib,
  flake,
  ...
}:

let
  cfg = config.home-manager.cli.yazi;
in
{
  options.home-manager.cli.yazi = {
    enable = lib.mkEnableOption "yazi config" // {
      default = config.home-manager.cli.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    icons.enable = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals cfg.icons.enable [
      config.home-manager.window-manager.theme.fonts.symbols.package
    ];

    programs.yazi = {
      enable = true;
      shellWrapperName = "yy";
      enableZshIntegration = true;
      flavors =
        let
          flavors = flake.inputs.yazi-flavors;
        in
        {
          catppuccin-frappe = "${flavors}/catppuccin-frappe.yazi";
          catppuccin-latte = "${flavors}/catppuccin-latte.yazi";
          catppuccin-macchiato = "${flavors}/catppuccin-macchiato.yazi";
          catppuccin-mocha = "${flavors}/catppuccin-mocha.yazi";
        };
      theme = {
        flavor = {
          use = "catppuccin-macchiato";
        };
        icon = lib.mkIf (!cfg.icons.enable) { rules = [ ]; };
        status = lib.mkIf (!cfg.icons.enable) {
          separator_open = "";
          separator_close = "";
        };
      };
    };
  };
}

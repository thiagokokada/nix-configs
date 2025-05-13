{
  config,
  lib,
  flake,
  ...
}:

let
  enableIcons = config.home-manager.cli.icons.enable;
  cfg = config.home-manager.cli.yazi;
in
{
  options.home-manager.cli.yazi = {
    enable = lib.mkEnableOption "yazi config" // {
      default = config.home-manager.cli.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals enableIcons [
      config.theme.fonts.symbols.package
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
        icon = lib.mkIf (!enableIcons) { rules = [ ]; };
        status = lib.mkIf (!enableIcons) {
          separator_open = "";
          separator_close = "";
        };
      };
    };
  };
}

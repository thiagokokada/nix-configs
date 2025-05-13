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
        # https://yazi-rs.github.io/docs/faq/#dont-like-nerd-fonts
        icon = lib.mkIf (!enableIcons) {
          globs = [ ];
          dirs = [ ];
          files = [ ];
          exts = [ ];
          conds = [ ];
        };
        status = lib.mkIf (!enableIcons) {
          sep_left = {
            open = "";
            close = "";
          };
          sep_right = {
            open = "";
            close = "";
          };
        };
      };
    };
  };
}

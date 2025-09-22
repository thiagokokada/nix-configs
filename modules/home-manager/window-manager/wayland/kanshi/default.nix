{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.home-manager.window-manager.wayland.kanshi;
in
{
  options.home-manager.window-manager.wayland.kanshi = {
    enable = lib.mkEnableOption "Kanshi config" // {
      default = config.home-manager.window-manager.wayland.enable;
    };
    extraSettings = lib.mkOption {
      description = "Additional hooks.";
      type = lib.types.listOf lib.types.attrs;
      default =
        let
          inherit (config.home-manager) hostName;
          configFile = ./${hostName}.nix;
        in
        lib.optionals (builtins.pathExists configFile) (import configFile);
    };
  };

  config = lib.mkIf cfg.enable {
    # Useful to get the list of monitors
    home.packages = with pkgs; [ wlr-randr ];

    services.kanshi = {
      enable = true;
      settings = cfg.extraSettings;
    };

    systemd.user.services.kanshi = {
      Service = {
        inherit (config.home-manager.window-manager.systemd.service)
          RestartSec
          RestartSteps
          RestartMaxDelaySec
          ;
      };
    };
  };
}

{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.window-manager.wayland.kanshi;
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
  hostConfigFileExists = builtins.pathExists hostConfigFile;
in
{
  imports = lib.optionals hostConfigFileExists [ hostConfigFile ];

  options.home-manager.window-manager.wayland.kanshi.enable = lib.mkEnableOption "Kanshi config" // {
    default = config.home-manager.window-manager.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    # Useful to get the list of monitors
    home.packages = with pkgs; [ wlr-randr ];

    services.kanshi.enable = hostConfigFileExists;

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

{
  lib,
  config,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.window-manager.wayland.kanshi;
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  options.home-manager.window-manager.wayland.kanshi.enable = lib.mkEnableOption "Kanshi config" // {
    default = config.home-manager.window-manager.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    services.kanshi.enable = true;

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

{
  lib,
  config,
  osConfig,
  ...
}:

let
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  options.home-manager.desktop.sway.kanshi.enable = lib.mkEnableOption "Kanshi config" // {
    default = config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.sway.kanshi.enable {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };

    systemd.user.services.kanshi = {
      Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
    };
  };
}

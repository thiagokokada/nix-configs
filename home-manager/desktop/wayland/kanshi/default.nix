{
  lib,
  config,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.desktop.wayland.kanshi;
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  options.home-manager.desktop.wayland.kanshi.enable = lib.mkEnableOption "Kanshi config" // {
    default = config.home-manager.desktop.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };

    systemd.user.services.kanshi = {
      Unit.ConditionEnvironment = "WAYLAND_DISPLAY";
      Service = {
        # Use exponential restart
        # https://enotty.pipebreaker.pl/posts/2024/01/how-systemd-exponential-restart-delay-works/
        RestartSec = "500ms";
        RestartSteps = 5;
        RestartMaxDelaySec = 5;
      };
    };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.easyeffects;
  inherit (config.home-manager) hostName;
  configFile = ./${hostName}.nix;
in
{
  options.home-manager.desktop.easyeffects = {
    enable = lib.mkEnableOption "EasyEffects config" // {
      default = config.home-manager.desktop.enable && builtins.pathExists configFile;
    };
    settings = lib.mkOption {
      description = "Host-specific EasyEffects settings";
      type = lib.types.submodule {
        options = {
          outputDevice = lib.mkOption {
            description = "PipeWire output device used for preset autoloading";
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          outputDeviceDescription = lib.mkOption {
            description = "Description of the PipeWire output device";
            type = lib.types.str;
            default = "";
          };
          presets = lib.mkOption {
            description = "EasyEffects presets to install";
            type = lib.types.attrs;
            default = { };
          };
          autoload = lib.mkOption {
            description = "Mapping of output device profiles to preset names";
            type = lib.types.attrsOf lib.types.str;
            default = { };
          };
        };
      };
      default = lib.optionalAttrs (builtins.pathExists configFile) (import configFile { inherit lib; });
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.autoload == { } || cfg.settings.outputDevice != null;
        message = "EasyEffects autoloading requires an output device";
      }
    ];

    services.easyeffects = {
      enable = true;
      extraPresets = cfg.settings.presets;
    };

    xdg.configFile = lib.mapAttrs' (
      profile: preset:
      lib.nameValuePair "easyeffects/autoload/output/${cfg.settings.outputDevice}:${profile}.json" {
        text = builtins.toJSON {
          device = cfg.settings.outputDevice;
          device-description = cfg.settings.outputDeviceDescription;
          device-profile = profile;
          preset-name = preset;
        };
      }
    ) cfg.settings.autoload;
  };
}

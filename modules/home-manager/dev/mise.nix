{ config, lib, ... }:

let
  cfg = config.home-manager.dev.mise;
in
{
  options.home-manager.dev.mise.enable = lib.mkEnableOption "mise-en-place config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.mise = {
      enable = true;
      globalConfig = {
        settings = {
          idiomatic_version_file_enable_tools = [
            "java"
            "node"
            "python"
            "ruby"
          ];
          trusted_config_paths = [
            "~/Projects"
            "~/Global-e"
          ];
        };
      };
    };
  };
}

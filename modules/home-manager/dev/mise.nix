{ config, lib, ... }:

let
  cfg = config.home-manager.dev.mise;
  javaAliasVersions = map toString (lib.range 8 50);
in
{
  options.home-manager.dev.mise = {
    enable = lib.mkEnableOption "mise-en-place config" // {
      default = config.home-manager.dev.enable;
    };
    java.defaultVendor = lib.mkOption {
      type = lib.types.str;
      description = "Java's default vendor";
      default = if config.home-manager.darwin.enable then "zulu" else "termurin";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mise = {
      enable = true;
      globalConfig = {
        settings = {
          always_keep_download = false;
          always_keep_install = false;
          java.shorthand_vendor = cfg.java.defaultVendor;
          idiomatic_version_file_enable_tools = [
            "java"
            "node"
            "python"
            "ruby"
          ];
          trusted_config_paths = [ "~/Projects" ];
        };
        # Workaround the fact that mise resolves `.java-version` set to just the
        # base number (e.g., `17`) to Oracle Java instead of the
        # `settings.java.shorthand_vendor`
        tool_alias.java.versions = lib.genAttrs javaAliasVersions (
          version: "${cfg.java.defaultVendor}-${version}"
        );
      };
    };
  };
}

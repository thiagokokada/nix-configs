{ lib, ... }:

with lib;
{
  options.meta = {
    username = mkOption {
      description = "Main username";
      type = types.str;
      default = "thiagoko";
    };
    email = mkOption {
      description = "Main e-mail";
      type = types.str;
      default = "thiagokokada@gmail.com";
    };
    configPath = mkOption {
      description = "Location of this config";
      type = types.path;
      default = "/etc/nixos";
    };
  };
}

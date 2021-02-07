{ lib, ... }:

with lib;
{
  options.my = {
    username = mkOption {
      description = "Main username";
      type = types.str;
      default = "thiagoko";
    };
  };
}

{ lib, ... }:

with lib;
{
  options.meta = {
    username = mkOption {
      description = "Main username";
      type = types.str;
      default = "thiagoko";
    };
  };
}

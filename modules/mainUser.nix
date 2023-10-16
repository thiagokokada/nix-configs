{ lib, ... }:

with lib;
{
  options.mainUser = {
    username = mkOption {
      description = "Main username";
      type = types.str;
      default = "thiagoko";
    };
    fullname = mkOption {
      description = "Main user full name";
      type = types.str;
      default = "Thiago Kenji Okada";
    };
    email = mkOption {
      description = "Main e-mail";
      type = types.str;
      default = "thiagokokada@gmail.com";
    };
  };
}
